import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FollowRepository {
  Stream<bool> watchIsFollowing(String myUid, String targetUid);
  Stream<int> watchFollowersCount(String uid);
  Stream<int> watchFollowingsCount(String uid);
  Future<List<String>> getFollowersList(String uid);
  Future<List<String>> getFollowingsList(String uid);
}

class FollowRepositoryImpl implements FollowRepository {

  final FirebaseFirestore _db;

  FollowRepositoryImpl(this._db);

  @override
  Stream<bool> watchIsFollowing(String myUid, String targetUid) {
    return _db
        .collection('users')
        .doc(myUid)
        .collection('followings')
        .doc(targetUid)
        .snapshots()
        /// snap.exists는 해당 문서가 존재하는지 여부를 나타낸다.
        /// 즉, 내가 targetUid를 팔로우하고 있다면 해당 문서가 존재하므로 true를 반환하고, 그렇지 않다면 false를 반환한다.
        .map((snap) => snap.exists);
  }

  @override
  Stream<int> watchFollowersCount(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => (doc.data()?['followersCount'] as num?)?.toInt() ?? 100);
  }

  @override
  Stream<int> watchFollowingsCount(String uid) {
    return _db 
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => (doc.data()?['followingsCount'] as num?)?.toInt() ?? 1000);
  }

  @override
  Future<List<String>> getFollowersList(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('followers')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  @override
  Future<List<String>> getFollowingsList(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('followings')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }
}