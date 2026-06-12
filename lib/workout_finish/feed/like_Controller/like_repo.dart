import 'package:cloud_firestore/cloud_firestore.dart';

abstract class LikeRepository {
  Stream<int> watchLikeCount(String workoutFinishId);
  Stream<bool> watchIsLiked({
    required String workoutFinishId,
    required String myUid,
  });
  Future<List<String>> getLikedUserIds(String workoutFinishId);
}

class LikeRepositoryImpl implements LikeRepository {

  final FirebaseFirestore _db;

  LikeRepositoryImpl(this._db);

  @override
  Stream<int> watchLikeCount(String workoutFinishId) {
    return _db.collection('workoutFinish')
        .doc(workoutFinishId)
        .snapshots()
        .map((doc) => (doc.data()?['likesCount'] as num?)?.toInt() ?? 0);
  }

  Future<List<String>> getLikedUserIds(String workoutFinishId) async {
    final snapshot = await _db.collection('workoutFinish')
        .doc(workoutFinishId)
        .collection('likes')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Stream<bool> watchIsLiked({
    required String workoutFinishId,
    required String myUid,
  }) {
    return _db.collection('workoutFinish')
        .doc(workoutFinishId)
        .collection('likes')
        .doc(myUid)
        .snapshots()
        .map((snap) => snap.exists);
  }
}
