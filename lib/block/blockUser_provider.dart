import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:home_function/core/firebase.dart';
import 'package:home_function/block/blockUser_repo.dart';

part 'blockUser_provider.g.dart';

@riverpod
BlockRepository blockRepository(Ref ref) {
  final auth = ref.read(firebaseAuthProvider);
  final db = ref.read(firestoreProvider);

  return BlockRepositoryImpl(
    auth: auth,
    db: db,
  );
}

@riverpod
Stream<List<String>> myBlockedUserIds(Ref ref) {
  final blockRepo = ref.read(blockRepositoryProvider);

  return blockRepo.watchMyBlockedUserIds();
}

@riverpod
Stream<bool> isBlockedByMe(
  Ref ref,
  String targetUid,
) {
  final blockRepo = ref.read(blockRepositoryProvider);

  return blockRepo.watchIsBlockedByMe(
    targetUid: targetUid,
  );
}

@riverpod
Future<bool> isBlockedEitherWay(
  Ref ref,
  String targetUid,
) async {
  final blockRepo = ref.read(blockRepositoryProvider);

  return blockRepo.isBlockedEitherWay(
    targetUid: targetUid,
  );
}