import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseInstallations _installations =
      FirebaseInstallations.instance;

  static StreamSubscription<String>? _tokenRefreshSubscription;

  /// 현재 이 기기에 등록된 사용자 UID
  static String? _registeredUid;

  /// 로그인 완료 후 호출
  static Future<bool> registerForUser({
    required String uid,
  }) async {
    final normalizedUid = uid.trim();

    if (normalizedUid.isEmpty) {
      debugPrint('FCM 등록 실패: UID가 비어 있습니다.');
      return false;
    }

    if (kIsWeb) {
      debugPrint('현재 NotificationService는 iOS/Android용입니다.');
      return false;
    }

    try {
      /*
       * 알림 권한 요청
       *
       * Android 13 이상과 iOS에서 필요
       */
      final notificationSettings =
          await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final authorizationStatus =
          notificationSettings.authorizationStatus;

      if (authorizationStatus ==
          AuthorizationStatus.denied) {
        debugPrint('사용자가 알림 권한을 거부했습니다.');
        return false;
      }

      /*
       * iOS 앱이 실행 중인 상태에서도
       * 알림 배너, 소리, 배지를 표시
       */
      await _messaging
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      /*
       * iOS는 APNs 토큰이 준비된 뒤
       * FCM 토큰을 요청해야 안정적임
       */
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsReady = await _waitForApnsToken();

        if (!apnsReady) {
          debugPrint(
            'APNs 토큰이 준비되지 않아 FCM 등록을 중단합니다.',
          );
          return false;
        }
      }

      final fcmToken = await _messaging.getToken();

      if (fcmToken == null || fcmToken.trim().isEmpty) {
        debugPrint('FCM 토큰을 가져오지 못했습니다.');
        return false;
      }

      await _saveDeviceToken(
        uid: normalizedUid,
        token: fcmToken,
      );

      _registeredUid = normalizedUid;

      /*
       * registerForUser가 여러 번 호출돼도
       * listener가 중복 등록되지 않도록 기존 구독 해제
       */
      await _tokenRefreshSubscription?.cancel();

      _tokenRefreshSubscription =
          _messaging.onTokenRefresh.listen(
        (newToken) async {
          final currentUid = _registeredUid;

          if (currentUid == null ||
              currentUid.trim().isEmpty) {
            return;
          }

          try {
            await _saveDeviceToken(
              uid: currentUid,
              token: newToken,
            );

            debugPrint('FCM 토큰 갱신 저장 완료');
          } catch (error, stackTrace) {
            debugPrint(
              'FCM 갱신 토큰 저장 실패: $error\n$stackTrace',
            );
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint(
            'FCM 토큰 갱신 감지 오류: '
            '$error\n$stackTrace',
          );
        },
      );

      debugPrint(
        'FCM 기기 등록 완료: '
        'uid=$normalizedUid, '
        'token=${_maskToken(fcmToken)}',
      );

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'FCM 기기 등록 실패: $error\n$stackTrace',
      );

      return false;
    }
  }

  /// iOS APNs 토큰이 준비될 때까지 최대 약 10초 대기
  static Future<bool> _waitForApnsToken() async {
    const maxAttempts = 20;
    const delay = Duration(milliseconds: 500);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final apnsToken = await _messaging.getAPNSToken();

      if (apnsToken != null && apnsToken.trim().isNotEmpty) {
        debugPrint('APNs 토큰 준비 완료');
        return true;
      }

      await Future<void>.delayed(delay);
    }

    return false;
  }

  /// Firestore에 현재 기기의 FCM 토큰 저장
  static Future<void> _saveDeviceToken({
    required String uid,
    required String token,
  }) async {
    final installationId =
        await _installations.getId();

    final platform =
        defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : 'android';

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('fcmDevices')
        .doc(installationId)
        .set(
      {
        'token': token.trim(),
        'installationId': installationId,
        'platform': platform,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// 로그아웃하기 전에 호출
  ///
  /// signOut() 이후에는 Firestore Rules 때문에
  /// 자신의 fcmDevices 문서를 삭제할 수 없으므로
  /// 반드시 로그아웃 전에 실행해야 함
  static Future<void> unregisterBeforeSignOut({
    required String uid,
  }) async {
    final normalizedUid = uid.trim();

    if (normalizedUid.isEmpty) {
      return;
    }

    try {
      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = null;

      final installationId =
          await _installations.getId();

      await _firestore
          .collection('users')
          .doc(normalizedUid)
          .collection('fcmDevices')
          .doc(installationId)
          .delete();

      /*
       * 현재 FCM 토큰도 무효화
       * 다음 로그인 때 새 토큰이 발급되고 다시 저장됨
       */
      await _messaging.deleteToken();

      _registeredUid = null;

      debugPrint(
        'FCM 기기 등록 해제 완료: uid=$normalizedUid',
      );
    } on FirebaseException catch (error, stackTrace) {
      /*
       * 문서가 이미 없어도 로그아웃 자체를 막지는 않음
       */
      debugPrint(
        'FCM 기기 등록 해제 중 Firebase 오류: '
        '${error.code} / ${error.message}\n$stackTrace',
      );

      _registeredUid = null;
    } catch (error, stackTrace) {
      debugPrint(
        'FCM 기기 등록 해제 실패: '
        '$error\n$stackTrace',
      );

      _registeredUid = null;
    }
  }

  static String _maskToken(String token) {
    if (token.length <= 12) {
      return '***';
    }

    return '${token.substring(0, 6)}'
        '...'
        '${token.substring(token.length - 6)}';
  }
}