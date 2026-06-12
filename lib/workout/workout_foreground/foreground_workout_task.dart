import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(WorkoutForegroundTaskHandler());
}

class WorkoutForegroundTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // 서비스 시작될 때 실행
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // 주기적으로 실행됨
    // 여기에서 타이머 업데이트, 위치 저장 트리거 등을 할 수 있음
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // 서비스 종료될 때 실행
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
  }
}