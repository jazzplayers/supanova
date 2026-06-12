import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'foreground_workout_task.dart';

Future<void> startWorkoutForegroundService() async {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'workout_tracking_channel',
      channelName: 'Workout Tracking',
      channelDescription: '운동 기록이 백그라운드에서 실행 중입니다.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
      autoRunOnBoot: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );

  final isRunning = await FlutterForegroundTask.isRunningService;

  if (isRunning) {
    await FlutterForegroundTask.restartService();
  } else {
    await FlutterForegroundTask.startService(
      notificationTitle: '운동 기록 중',
      notificationText: '거리와 시간이 기록되고 있습니다.',
      callback: startCallback,
    );
  }
}

Future<void> stopWorkoutForegroundService() async {
  await FlutterForegroundTask.stopService();
}