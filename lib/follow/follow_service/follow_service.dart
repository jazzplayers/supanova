import 'package:cloud_functions/cloud_functions.dart';

/// follow_service.dart에서는 Cloud Functions 호출만을 담당한다.

class FollowService {
    final FirebaseFunctions _functions;
  FollowService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  Future<void> followUser(String targetUid) async {
    await _functions.httpsCallable('followUser').call({
      'targetUid': targetUid,
    });
  }

  Future<void> unfollowUser(String targetUid) async {
    await _functions.httpsCallable('unfollowUser').call({
      'targetUid': targetUid,
    });
  }
}