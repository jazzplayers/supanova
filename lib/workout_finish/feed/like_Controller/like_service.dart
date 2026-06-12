import 'package:cloud_functions/cloud_functions.dart';

class LikeService {
  final FirebaseFunctions _functions;

  LikeService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  Future<void> feedLike(String workoutFinishId) async {
    await _functions.httpsCallable('feedLike').call({
      'workoutFinishId': workoutFinishId,
    });
  }
  Future<void> feedUnlike(String workoutFinishId) async {
    await _functions.httpsCallable('feedUnlike').call({
      'workoutFinishId': workoutFinishId,
    });
  }
}