import 'package:cloud_firestore/cloud_firestore.dart';
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

  String _googleTempDisplayName(String uid) {
    return 'user_${uid.substring(0, 15)}';
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
      throw Exception('[firebase_auth/no-current-user] No user currently signed in.');
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
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('로그인 실패: code=${e.code}, message=${e.message}');
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
      throw Exception('회원가입 후 로그인 상태 확인 실패: code=${e.code}, message=${e.message}');
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

      final tempDisplayName = _googleTempDisplayName(user.uid);
      final tempDisplayNameKey = tempDisplayName;
      final displayNameRef =
          _db.collection('displayNames').doc(tempDisplayNameKey);

      String authDisplayNameToSet = tempDisplayName;

      try {
        await _db.runTransaction((tx) async {
          final userDoc = await tx.get(userRef);

          if (userDoc.exists) {
            final data = userDoc.data();

            final currentDisplayName =
                (data?['displayName'] as String?)?.trim() ?? '';

            final currentDisplayNameKey =
                (data?['displayNameKey'] as String?)?.trim() ?? '';

            final savedProfileImageUrl =
                (data?['profileImageUrl'] as String?)?.trim() ?? '';

            final shouldClearGooglePhoto = _isSameAsGooglePhoto(
              savedProfileImageUrl: savedProfileImageUrl,
              googlePhotoUrl: user.photoURL,
            );

            if (currentDisplayName.isNotEmpty &&
                currentDisplayNameKey.isNotEmpty) {
              authDisplayNameToSet = currentDisplayName;

              // 기존에 구글 사진이 저장되어 있던 계정이면 자동으로 비움.
              // 사용자가 앱에서 직접 올린 사진이면 유지됨.
              if (shouldClearGooglePhoto) {
                tx.update(userRef, {
                  'uid': user.uid,
                  'profileImageUrl': '',
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }

              return;
            }

            // 기존 users 문서가 있지만 닉네임 정보가 비어 있는 경우 보정
            tx.update(userRef, {
              'uid': user.uid,
              'email': user.email ?? '',
              'displayName': tempDisplayName,
              'displayNameKey': tempDisplayNameKey,

              // 구글 프로필 사진 저장하지 않음
              'profileImageUrl': '',

              'bio': (data?['bio'] as String?) ?? '',
              'workoutCount': (data?['workoutCount'] as num?) ?? 0,
              'followersCount': (data?['followersCount'] as num?) ?? 0,
              'followingsCount': (data?['followingsCount'] as num?) ?? 0,
              'totalDistance': (data?['totalDistance'] as num?) ?? 0.0,
              'isPrivate': (data?['isPrivate'] as bool?) ?? false,
              'updatedAt': FieldValue.serverTimestamp(),
            });

            tx.set(displayNameRef, {
              'uid': user.uid,
              'displayName': tempDisplayName,
              'displayNameKey': tempDisplayNameKey,
              'createdAt': FieldValue.serverTimestamp(),
            });

            authDisplayNameToSet = tempDisplayName;
            return;
          }

          // 신규 구글 가입 유저 생성
          tx.set(userRef, {
            'uid': user.uid,
            'email': user.email ?? '',
            'displayName': tempDisplayName,
            'displayNameKey': tempDisplayNameKey,

            // 구글 프로필 사진 저장하지 않음
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
            'uid': user.uid,
            'displayName': tempDisplayName,
            'displayNameKey': tempDisplayNameKey,
            'createdAt': FieldValue.serverTimestamp(),
          });

          authDisplayNameToSet = tempDisplayName;
        });

        try {
          final currentUser = _auth.currentUser;

          if (currentUser != null && currentUser.uid == user.uid) {
            await currentUser.updateDisplayName(authDisplayNameToSet);

            // FirebaseAuth 프로필에도 구글 사진을 남기지 않음
            await currentUser.updatePhotoURL(null);
          }
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
    return _auth.authStateChanges();
  }

  @override
  Future<Auth?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return Auth.fromJson(doc.data()!);
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

      return Auth.fromJson(doc.data()!);
    });
  }

  @override
  Future<void> updateUserData({
    required String uid,
    String? displayName,
    String? profileImageUrl,
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
            throw Exception('이미 사용 중인 닉네임입니다.');
          }

          transaction.update(userRef, {
            'uid': uid,
            'displayName': newDisplayName,
            'displayNameKey': newDisplayNameKey,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          transaction.set(newDisplayNameRef, {
            'uid': uid,
            'displayName': newDisplayName,
            'displayNameKey': newDisplayNameKey,
            'createdAt': FieldValue.serverTimestamp(),
          });

          if (oldDisplayNameRef != null &&
              oldDisplayNameDoc != null &&
              oldDisplayNameDoc.exists) {
            transaction.delete(oldDisplayNameRef);
          }
        });

        try {
          await currentUser.updateDisplayName(newDisplayName);
        } catch (_) {}
      }

      if (profileImageUrl != null) {
        await userRef.update({
          'uid': uid,
          'profileImageUrl': profileImageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

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

      return !doc.exists;
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

    final uid = user.uid;
    final userRef = _db.collection('users').doc(uid);

    try {
      final userDoc = await userRef.get();

      String? displayNameKey;

      if (userDoc.exists && userDoc.data() != null) {
        displayNameKey =
            (userDoc.data()!['displayNameKey'] as String?)?.trim().toLowerCase();
      }

      final batch = _db.batch();

      if (displayNameKey != null && displayNameKey.isNotEmpty) {
        final displayNameRef =
            _db.collection('displayNames').doc(displayNameKey);
        batch.delete(displayNameRef);
      }

      batch.delete(userRef);

      await batch.commit();

      await user.delete();

      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}

      try {
        await _auth.signOut();
      } catch (_) {}
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('보안을 위해 다시 로그인한 뒤 계정을 삭제해주세요.');
      }

      throw Exception('계정 삭제 실패: code=${e.code}, message=${e.message}');
    } on FirebaseException catch (e) {
      throw Exception(
        '계정 삭제 Firestore 실패: code=${e.code}, message=${e.message}',
      );
    } catch (e) {
      throw Exception('계정 삭제 실패: $e');
    }
  }
}