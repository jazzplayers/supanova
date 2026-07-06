import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BlockRepository {
  Future<void> blockUser({
    required String targetUid,
  });

  Future<void> unblockUser({
    required String targetUid,
  });

  Stream<List<String>> watchMyBlockedUserIds();

  Future<List<String>> getMyBlockedUserIds();

  Stream<bool> watchIsBlockedByMe({
    required String targetUid,
  });

  Future<bool> isBlockedByMe({
    required String targetUid,
  });

  Future<bool> isBlockedEitherWay({
    required String targetUid,
  });
}

class BlockRepositoryImpl implements BlockRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  BlockRepositoryImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore db,
    FirebaseFunctions? functions,
  })  : _auth = auth,
        _db = db,
        _functions = functions ??
            FirebaseFunctions.instanceFor(
              region: 'asia-northeast3',
            );

  String get _currentUid {
    final uid = _auth.currentUser?.uid;

    if (uid == null || uid.trim().isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    return uid;
  }

  void _validateTargetUid(String targetUid) {
    if (targetUid.trim().isEmpty) {
      throw Exception('차단할 사용자 정보가 올바르지 않습니다.');
    }

    if (_auth.currentUser?.uid == targetUid.trim()) {
      throw Exception('자기 자신은 차단할 수 없습니다.');
    }
  }

  @override
  Future<void> blockUser({
    required String targetUid,
  }) async {
    try {
      final trimmedTargetUid = targetUid.trim();

      _validateTargetUid(trimmedTargetUid);

      final callable = _functions.httpsCallable('blockUser');

      await callable.call({
        'targetUid': trimmedTargetUid,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        '차단 실패: code=${e.code}, message=${e.message}',
      );
    } catch (e) {
      throw Exception('차단 실패: $e');
    }
  }

  @override
  Future<void> unblockUser({
    required String targetUid,
  }) async {
    try {
      final trimmedTargetUid = targetUid.trim();

      _validateTargetUid(trimmedTargetUid);

      final callable = _functions.httpsCallable('unblockUser');

      await callable.call({
        'targetUid': trimmedTargetUid,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        '차단 해제 실패: code=${e.code}, message=${e.message}',
      );
    } catch (e) {
      throw Exception('차단 해제 실패: $e');
    }
  }

  @override
  Stream<List<String>> watchMyBlockedUserIds() {
    final uid = _currentUid;

    return _db
        .collection('users')
        .doc(uid)
        .collection('blockedUsers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  Future<List<String>> getMyBlockedUserIds() async {
    try {
      final uid = _currentUid;

      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('blockedUsers')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('차단 목록 가져오기 실패: $e');
    }
  }

  @override
  Stream<bool> watchIsBlockedByMe({
    required String targetUid,
  }) {
    final uid = _currentUid;
    final trimmedTargetUid = targetUid.trim();

    if (trimmedTargetUid.isEmpty) {
      return Stream.value(false);
    }

    return _db
        .collection('users')
        .doc(uid)
        .collection('blockedUsers')
        .doc(trimmedTargetUid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  @override
  Future<bool> isBlockedByMe({
    required String targetUid,
  }) async {
    try {
      final uid = _currentUid;
      final trimmedTargetUid = targetUid.trim();

      if (trimmedTargetUid.isEmpty) {
        return false;
      }

      final doc = await _db
          .collection('users')
          .doc(uid)
          .collection('blockedUsers')
          .doc(trimmedTargetUid)
          .get();

      return doc.exists;
    } catch (e) {
      throw Exception('차단 여부 확인 실패: $e');
    }
  }

  @override
  Future<bool> isBlockedEitherWay({
    required String targetUid,
  }) async {
    try {
      final uid = _currentUid;
      final trimmedTargetUid = targetUid.trim();

      if (trimmedTargetUid.isEmpty || uid == trimmedTargetUid) {
        return false;
      }

      final myBlockId = '${uid}_$trimmedTargetUid';
      final targetBlockId = '${trimmedTargetUid}_$uid';

      final results = await Future.wait([
        _db.collection('blocks').doc(myBlockId).get(),
        _db.collection('blocks').doc(targetBlockId).get(),
      ]);

      return results.any((doc) => doc.exists);
    } catch (e) {
      throw Exception('차단 관계 확인 실패: $e');
    }
  }
}