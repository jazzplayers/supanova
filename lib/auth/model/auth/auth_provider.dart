import 'package:home_function/auth/model/auth/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:home_function/core/firebase.dart';

import 'auth.dart';

part 'auth_provider.g.dart';

@riverpod
UserAuthRepository userAuthRepository(Ref ref) {
  final auth = ref.read(firebaseAuthProvider);
  final db = ref.read(firestoreProvider);

  return UserAuthRepositoryImpl(auth, db);
}

@riverpod
Stream<Auth?> userAuthData(Ref ref, String uid) {
  final authRepo = ref.read(userAuthRepositoryProvider);

  return authRepo.watchUserData(uid);
}

@riverpod
Future<void> userSignOut(Ref ref) async {
  final authRepo = ref.read(userAuthRepositoryProvider);

  await authRepo.userSignOut();
}

@riverpod
Future<void> deleteAccount(Ref ref) async {
  final authRepo = ref.read(userAuthRepositoryProvider);

  await authRepo.deleteAccount();
}

@riverpod
String? myUid(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);

  return auth.currentUser?.uid;
}

@riverpod
Future<void> updateUserData(
  Ref ref, {
  required String uid,
  String? displayName,
  String? profileImageUrl,
}) async {
  final authRepo = ref.read(userAuthRepositoryProvider);

  await authRepo.updateUserData(
    uid: uid,
    displayName: displayName,
    profileImageUrl: profileImageUrl,
  );
}

@riverpod
Future<bool> isDisplayNameAvailable(Ref ref, String displayName) async {
  final authRepo = ref.read(userAuthRepositoryProvider);

  return await authRepo.isDisplayNameAvailable(displayName);
}

@riverpod
Future<void> signInWithGoogle(Ref ref) async {
  final authRepo = ref.read(userAuthRepositoryProvider);

  await authRepo.signInWithGoogle();
}   