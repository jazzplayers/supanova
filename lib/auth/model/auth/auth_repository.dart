import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth.dart';

abstract class UserAuthRepository {
  Future<UserCredential> userSignIn({
    required String email,
    required String password,
  });

  Future<UserCredential> userSignUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> userSignOut();

  Stream<User?> userAuthStateChanges();

  User? get currentUser;

  Future<Auth?> getUserData(String uid);

  Stream<Auth?> watchUserData(String uid);

  Future<void> updateUserData({
    required String uid,
    String? displayName,
    String? profileImageUrl,
    String? bio,
  });

  Future<bool> isDisplayNameAvailable(String displayName);

  Future<UserCredential> signInWithGoogle();

  Future<void> deleteAccount();
}

class UserAuthRepositoryImpl implements UserAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  UserAuthRepositoryImpl(this._auth, this._db);

  String _normalizeDisplayName(String value) {
    return value.trim().toLowerCase();
  }

  String _safeUidPart(String uid) {
    final cleaned = uid.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]'),
          '',
        );

    if (cleaned.isEmpty) {
      return 'user';
    }

    return cleaned;
  }

  String _googleTempDisplayName(
    String uid, {
    int attempt = 0,
  }) {
    final safeUid = _safeUidPart(uid);

    if (attempt == 0) {
      final maxUidLength = 20 - 'user_'.length;
      final end = math.min(safeUid.length, maxUidLength);
      return 'user_${safeUid.substring(0, end)}';
    }

    final suffix = attempt.toString().padLeft(2, '0');
    final maxUidLength = 20 - 'user_'.length - suffix.length;
    final end = math.min(safeUid.length, maxUidLength);

    return 'user_${safeUid.substring(0, end)}$suffix';
  }

  bool _isValidDisplayNameValue(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty && trimmed.length <= 20;
  }

  bool _isSameAsGooglePhoto({
    required String? savedProfileImageUrl,
    required String? googlePhotoUrl,
  }) {
    final saved = savedProfileImageUrl?.trim() ?? '';
    final google = googlePhotoUrl?.trim() ?? '';

    if (saved.isEmpty || google.isEmpty) {
      return false;
    }

    return saved == google;
  }

  Future<_ReservedDisplayName> _reserveDisplayNameInTransaction({
    required Transaction tx,
    required String uid,
    String? preferredDisplayName,
  }) async {
    final preferred = preferredDisplayName?.trim() ?? '';

    if (_isValidDisplayNameValue(preferred)) {
      final preferredKey = _normalizeDisplayName(preferred);
      final preferredRef = _db.collection('displayNames').doc(preferredKey);
      final preferredDoc = await tx.get(preferredRef);

      if (!preferredDoc.exists) {
        return _ReservedDisplayName(
          displayName: preferred,
          displayNameKey: preferredKey,
          ref: preferredRef,
          shouldCreateDisplayNameDoc: true,
        );
      }

      final data = preferredDoc.data() as Map<String, dynamic>?;
      final ownerUid = data?['uid'] as String?;

      if (ownerUid == uid) {
        return _ReservedDisplayName(
          displayName: preferred,
          displayNameKey: preferredKey,
          ref: preferredRef,
          shouldCreateDisplayNameDoc: false,
        );
      }
    }

    for (int attempt = 0; attempt < 100; attempt++) {
      final tempDisplayName = _googleTempDisplayName(
        uid,
        attempt: attempt,
      );
      final tempDisplayNameKey = _normalizeDisplayName(tempDisplayName);
      final tempRef = _db.collection('displayNames').doc(tempDisplayNameKey);
      final tempDoc = await tx.get(tempRef);

      if (!tempDoc.exists) {
        return _ReservedDisplayName(
          displayName: tempDisplayName,
          displayNameKey: tempDisplayNameKey,
          ref: tempRef,
          shouldCreateDisplayNameDoc: true,
        );
      }

      final data = tempDoc.data() as Map<String, dynamic>?;
      final ownerUid = data?['uid'] as String?;

      if (ownerUid == uid) {
        return _ReservedDisplayName(
          displayName: tempDisplayName,
          displayNameKey: tempDisplayNameKey,
          ref: tempRef,
          shouldCreateDisplayNameDoc: false,
        );
      }
    }

    throw Exception('사용 가능한 임시 닉네임을 만들지 못했습니다.');
  }

  Map<String, dynamic> _defaultUserCreateData({
    required User user,
    required String displayName,
    required String displayNameKey,
  }) {
    return {
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName': displayName,
      'displayNameKey': displayNameKey,
      'profileImageUrl': '',
      'bio': '',
      'workoutCount': 0,
      'followersCount': 0,
      'followingsCount': 0,
      'totalDistance': 0.0,
      'isPrivate': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _missingUserFieldUpdates({
    required String uid,
    required Map<String, dynamic> data,
    required String email,
  }) {
    final updates = <String, dynamic>{};

    if (!data.containsKey('uid')) {
      updates['uid'] = uid;
    }

    if (!data.containsKey('email')) {
      updates['email'] = email;
    }

    if (!data.containsKey('workoutCount')) {
      updates['workoutCount'] = 0;
    }

    if (!data.containsKey('followersCount')) {
      updates['followersCount'] = 0;
    }

    if (!data.containsKey('followingsCount')) {
      updates['followingsCount'] = 0;
    }

    if (!data.containsKey('totalDistance')) {
      updates['totalDistance'] = 0.0;
    }

    if (!data.containsKey('isPrivate')) {
      updates['isPrivate'] = false;
    }

    if (!data.containsKey('bio')) {
      updates['bio'] = '';
    }

    if (!data.containsKey('profileImageUrl')) {
      updates['profileImageUrl'] = '';
    }

    if (!data.containsKey('createdAt')) {
      updates['createdAt'] = FieldValue.serverTimestamp();
    }

    return updates;
  }

  Future<String> _ensureUserFields(String uid) async {
    final currentUser = _auth.currentUser;
    final userRef = _db.collection('users').doc(uid);

    String displayNameToSet = '';

    await _db.runTransaction((tx) async {
      final userDoc = await tx.get(userRef);

      if (!userDoc.exists) {
        return;
      }

      final data = userDoc.data() ?? <String, dynamic>{};

      final email = currentUser?.email ?? data['email'] as String? ?? '';

      final currentDisplayName =
          (data['displayName'] as String?)?.trim() ?? '';

      final currentDisplayNameKey =
          (data['displayNameKey'] as String?)?.trim().toLowerCase() ?? '';

      final hasValidDisplayName = _isValidDisplayNameValue(
            currentDisplayName,
          ) &&
          currentDisplayNameKey.isNotEmpty &&
          currentDisplayNameKey.length <= 20;

      final reserved = await _reserveDisplayNameInTransaction(
        tx: tx,
        uid: uid,
        preferredDisplayName: hasValidDisplayName ? currentDisplayName : null,
      );

      displayNameToSet = reserved.displayName;

      final updates = _missingUserFieldUpdates(
        uid: uid,
        data: data,
        email: email,
      );

      if (!hasValidDisplayName ||
          currentDisplayName != reserved.displayName ||
          currentDisplayNameKey != reserved.displayNameKey) {
        updates['displayName'] = reserved.displayName;
        updates['displayNameKey'] = reserved.displayNameKey;
      }

      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();

        tx.set(
          userRef,
          updates,
          SetOptions(merge: true),
        );
      }

      if (reserved.shouldCreateDisplayNameDoc) {
        tx.set(reserved.ref, {
          'uid': uid,
          'displayName': reserved.displayName,
          'displayNameKey': reserved.displayNameKey,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });

    return displayNameToSet;
  }

  Future<User> _ensureSignedInWithEmail({
    required User expectedUser,
    required String email,
    required String password,
  }) async {
    final current = _auth.currentUser;

    if (current != null && current.uid == expectedUser.uid) {
      return current;
    }

    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final signedInUser = credential.user;

    if (signedInUser == null || signedInUser.uid != expectedUser.uid) {
      throw Exception(
        '[firebase_auth/no-current-user] No user currently signed in.',
      );
    }

    return signedInUser;
  }

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> userSignIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        try {
          final displayName = await _ensureUserFields(user.uid);

          if (displayName.isNotEmpty && _auth.currentUser?.uid == user.uid) {
            await _auth.currentUser?.updateDisplayName(displayName);
          }
        } catch (_) {
          // 필드 보정 실패 때문에 로그인 자체가 막히지 않게 둠.
        }
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception('로그인 실패: code=${e.code}, message=${e.message}');
    } catch (e) {
      throw Exception('로그인 실패: $e');
    }
  }

  @override
  Future<UserCredential> userSignUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedDisplayName = displayName.trim();
    final displayNameKey = _normalizeDisplayName(trimmedDisplayName);

    if (trimmedDisplayName.isEmpty) {
      throw Exception('닉네임을 입력해주세요.');
    }

    if (trimmedDisplayName.length > 20) {
      throw Exception('닉네임은 20자 이하로 입력해주세요.');
    }

    UserCredential userCredential;

    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('회원가입 실패: code=${e.code}, message=${e.message}');
    }

    final createdUser = userCredential.user;

    if (createdUser == null) {
      throw Exception('사용자 계정 생성 실패');
    }

    User activeUser;

    try {
      activeUser = await _ensureSignedInWithEmail(
        expectedUser: createdUser,
        email: trimmedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(
        '회원가입 후 로그인 상태 확인 실패: code=${e.code}, message=${e.message}',
      );
    } catch (e) {
      throw Exception('회원가입 후 로그인 상태 확인 실패: $e');
    }

    final userRef = _db.collection('users').doc(activeUser.uid);
    final displayNameRef = _db.collection('displayNames').doc(displayNameKey);

    try {
      await _db.runTransaction((tx) async {
        final displayNameDoc = await tx.get(displayNameRef);

        if (displayNameDoc.exists) {
          throw Exception('이미 사용 중인 닉네임입니다.');
        }

        tx.set(userRef, {
          'uid': activeUser.uid,
          'email': trimmedEmail,
          'displayName': trimmedDisplayName,
          'displayNameKey': displayNameKey,
          'profileImageUrl': '',
          'bio': '',
          'workoutCount': 0,
          'followersCount': 0,
          'followingsCount': 0,
          'totalDistance': 0.0,
          'isPrivate': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        tx.set(displayNameRef, {
          'uid': activeUser.uid,
          'displayName': trimmedDisplayName,
          'displayNameKey': displayNameKey,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      try {
        final currentUser = _auth.currentUser;

        if (currentUser != null && currentUser.uid == activeUser.uid) {
          await currentUser.delete();
        }
      } catch (_) {}

      throw Exception('사용자 정보 저장 실패: $e');
    }

    try {
      activeUser = await _ensureSignedInWithEmail(
        expectedUser: activeUser,
        email: trimmedEmail,
        password: password,
      );
    } catch (_) {}

    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null && currentUser.uid == activeUser.uid) {
        await currentUser.updateDisplayName(trimmedDisplayName);
        await currentUser.updatePhotoURL(null);
      }
    } catch (_) {}

    try {
      await _ensureUserFields(activeUser.uid);
    } catch (_) {}

    return userCredential;
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();

      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('구글 로그인 유저 정보를 가져오지 못했습니다.');
      }

      final userRef = _db.collection('users').doc(user.uid);

      String authDisplayNameToSet = '';

      try {
        await _db.runTransaction((tx) async {
          final userDoc = await tx.get(userRef);

          if (!userDoc.exists) {
            final reserved = await _reserveDisplayNameInTransaction(
              tx: tx,
              uid: user.uid,
            );

            tx.set(
              userRef,
              _defaultUserCreateData(
                user: user,
                displayName: reserved.displayName,
                displayNameKey: reserved.displayNameKey,
              ),
            );

            if (reserved.shouldCreateDisplayNameDoc) {
              tx.set(reserved.ref, {
                'uid': user.uid,
                'displayName': reserved.displayName,
                'displayNameKey': reserved.displayNameKey,
                'createdAt': FieldValue.serverTimestamp(),
              });
            }

            authDisplayNameToSet = reserved.displayName;
            return;
          }

          final data = userDoc.data() ?? <String, dynamic>{};

          final currentDisplayName =
              (data['displayName'] as String?)?.trim() ?? '';

          final currentDisplayNameKey =
              (data['displayNameKey'] as String?)?.trim().toLowerCase() ?? '';

          final hasValidCurrentDisplayName = _isValidDisplayNameValue(
                currentDisplayName,
              ) &&
              currentDisplayNameKey.isNotEmpty &&
              currentDisplayNameKey.length <= 20;

          final reserved = await _reserveDisplayNameInTransaction(
            tx: tx,
            uid: user.uid,
            preferredDisplayName:
                hasValidCurrentDisplayName ? currentDisplayName : null,
          );

          final savedProfileImageUrl =
              (data['profileImageUrl'] as String?)?.trim() ?? '';

          final shouldClearGooglePhoto = _isSameAsGooglePhoto(
            savedProfileImageUrl: savedProfileImageUrl,
            googlePhotoUrl: user.photoURL,
          );

          final updates = _missingUserFieldUpdates(
            uid: user.uid,
            data: data,
            email: user.email ?? '',
          );

          updates['email'] = user.email ?? data['email'] as String? ?? '';

          if (!hasValidCurrentDisplayName ||
              currentDisplayName != reserved.displayName ||
              currentDisplayNameKey != reserved.displayNameKey) {
            updates['displayName'] = reserved.displayName;
            updates['displayNameKey'] = reserved.displayNameKey;
          }

          if (shouldClearGooglePhoto) {
            updates['profileImageUrl'] = '';
          }

          if (updates.isNotEmpty) {
            updates['updatedAt'] = FieldValue.serverTimestamp();

            tx.set(
              userRef,
              updates,
              SetOptions(merge: true),
            );
          }

          if (reserved.shouldCreateDisplayNameDoc) {
            tx.set(reserved.ref, {
              'uid': user.uid,
              'displayName': reserved.displayName,
              'displayNameKey': reserved.displayNameKey,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

          authDisplayNameToSet = reserved.displayName;
        });

        try {
          final currentUser = _auth.currentUser;

          if (currentUser != null && currentUser.uid == user.uid) {
            if (authDisplayNameToSet.isNotEmpty) {
              await currentUser.updateDisplayName(authDisplayNameToSet);
            }
            await currentUser.updatePhotoURL(null);
          }
        } catch (_) {}

        try {
          await _ensureUserFields(user.uid);
        } catch (_) {}

        return userCredential;
      } catch (e) {
        throw Exception('구글 로그인 Firestore 실패: $e');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('구글 로그인 실패: code=${e.code}, message=${e.message}');
    } on FirebaseException catch (e) {
      throw Exception(
        '구글 로그인 Firestore 실패: code=${e.code}, message=${e.message}',
      );
    } catch (e) {
      throw Exception('구글 로그인 실패: $e');
    }
  }

  @override
  Future<void> userSignOut() async {
    try {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}

      await _auth.signOut();
    } catch (e) {
      throw Exception('로그아웃 실패: $e');
    }
  }

  @override
  Stream<User?> userAuthStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user != null) {
        try {
          final displayName = await _ensureUserFields(user.uid);

          if (displayName.isNotEmpty && _auth.currentUser?.uid == user.uid) {
            await _auth.currentUser?.updateDisplayName(displayName);
          }
        } catch (_) {
          // 앱 시작 시 필드 보정 실패가 auth stream을 깨지 않게 둠.
        }
      }

      return user;
    });
  }

  @override
  Future<Auth?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return Auth.fromFirestore(doc);
    } catch (e) {
      throw Exception('사용자 데이터 가져오기 실패: $e');
    }
  }

  @override
  Stream<Auth?> watchUserData(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return Auth.fromFirestore(doc);
    });
  }

  @override
  Future<void> updateUserData({
    required String uid,
    String? displayName,
    String? profileImageUrl,
    String? bio,
  }) async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception('로그인이 필요합니다.');
      }

      if (currentUser.uid != uid) {
        throw Exception('본인 프로필만 수정할 수 있습니다.');
      }

      final userRef = _db.collection('users').doc(uid);

      String? newDisplayName;
      String? newDisplayNameKey;

      if (displayName != null) {
        newDisplayName = displayName.trim();
        newDisplayNameKey = _normalizeDisplayName(newDisplayName);

        if (newDisplayName.isEmpty) {
          throw Exception('닉네임을 입력해주세요.');
        }

        if (newDisplayName.length > 20) {
          throw Exception('닉네임은 20자 이하로 입력해주세요.');
        }
      }

      if (newDisplayName != null && newDisplayNameKey != null) {
        await _db.runTransaction((transaction) async {
          final userDoc = await transaction.get(userRef);

          if (!userDoc.exists || userDoc.data() == null) {
            throw Exception('사용자 정보를 찾을 수 없습니다.');
          }

          final userData = userDoc.data()!;

          final oldDisplayName =
              (userData['displayName'] as String?)?.trim() ?? '';

          final oldDisplayNameKey =
              (userData['displayNameKey'] as String?)?.trim().toLowerCase() ??
                  _normalizeDisplayName(oldDisplayName);

          if (oldDisplayNameKey == newDisplayNameKey) {
            transaction.update(userRef, {
              'uid': uid,
              'displayName': newDisplayName,
              'displayNameKey': newDisplayNameKey,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            return;
          }

          final newDisplayNameRef =
              _db.collection('displayNames').doc(newDisplayNameKey);

          final oldDisplayNameRef = oldDisplayNameKey.isNotEmpty
              ? _db.collection('displayNames').doc(oldDisplayNameKey)
              : null;

          final newDisplayNameDoc = await transaction.get(newDisplayNameRef);

          final oldDisplayNameDoc = oldDisplayNameRef == null
              ? null
              : await transaction.get(oldDisplayNameRef);

          if (newDisplayNameDoc.exists) {
            final data = newDisplayNameDoc.data() as Map<String, dynamic>?;
            final ownerUid = data?['uid'] as String?;

            if (ownerUid != uid) {
              throw Exception('이미 사용 중인 닉네임입니다.');
            }
          }

          transaction.update(userRef, {
            'uid': uid,
            'displayName': newDisplayName,
            'displayNameKey': newDisplayNameKey,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          if (!newDisplayNameDoc.exists) {
            transaction.set(newDisplayNameRef, {
              'uid': uid,
              'displayName': newDisplayName,
              'displayNameKey': newDisplayNameKey,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

          if (oldDisplayNameRef != null &&
              oldDisplayNameDoc != null &&
              oldDisplayNameDoc.exists) {
            final oldData = oldDisplayNameDoc.data() as Map<String, dynamic>?;
            final oldOwnerUid = oldData?['uid'] as String?;

            if (oldOwnerUid == uid) {
              transaction.delete(oldDisplayNameRef);
            }
          }
        });

        try {
          await currentUser.updateDisplayName(newDisplayName);
        } catch (_) {}
      }

      final normalUpdates = <String, dynamic>{};

      if (profileImageUrl != null) {
        normalUpdates['profileImageUrl'] = profileImageUrl;
      }

      if (bio != null) {
        normalUpdates['bio'] = bio.trim();
      }

      if (normalUpdates.isNotEmpty) {
        normalUpdates['uid'] = uid;
        normalUpdates['updatedAt'] = FieldValue.serverTimestamp();

        await userRef.update(normalUpdates);
      }

      if (profileImageUrl != null) {
        try {
          await currentUser.updatePhotoURL(profileImageUrl);
        } catch (_) {}
      }
    } on FirebaseException catch (e) {
      throw Exception(
        '사용자 데이터 업데이트 실패: code=${e.code}, message=${e.message}',
      );
    } catch (e) {
      throw Exception('사용자 데이터 업데이트 실패: $e');
    }
  }

  @override
  Future<bool> isDisplayNameAvailable(String displayName) async {
    try {
      final trimmedDisplayName = displayName.trim();

      if (trimmedDisplayName.isEmpty) {
        return false;
      }

      if (trimmedDisplayName.length > 20) {
        return false;
      }

      final displayNameKey = _normalizeDisplayName(trimmedDisplayName);

      final doc = await _db.collection('displayNames').doc(displayNameKey).get();

      if (!doc.exists) {
        return true;
      }

      final ownerUid = doc.data()?['uid'] as String?;
      final currentUid = _auth.currentUser?.uid;

      return currentUid != null && ownerUid == currentUid;
    } catch (e) {
      throw Exception('닉네임 중복 확인 실패: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('deleteUserAccount');

      await callable.call();

      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}

      try {
        await _auth.signOut();
      } catch (_) {}
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        '계정 삭제 실패: code=${e.code}, message=${e.message}',
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(
        '계정 삭제 후 로그아웃 실패: code=${e.code}, message=${e.message}',
      );
    } catch (e) {
      throw Exception('계정 삭제 실패: $e');
    }
  }
}

class _ReservedDisplayName {
  const _ReservedDisplayName({
    required this.displayName,
    required this.displayNameKey,
    required this.ref,
    required this.shouldCreateDisplayNameDoc,
  });

  final String displayName;
  final String displayNameKey;
  final DocumentReference<Map<String, dynamic>> ref;
  final bool shouldCreateDisplayNameDoc;
}