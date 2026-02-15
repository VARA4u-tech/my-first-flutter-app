import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    late String timeZoneName;
    try {
      timeZoneName = await FlutterTimezone.getLocalTimezone();
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        // Fallback for common aliases (e.g., Calcutta -> Kolkata)
        if (timeZoneName == 'Asia/Calcutta') {
          tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
          timeZoneName = 'Asia/Kolkata';
        } else {
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('Warning: Timezone mapping failed for $timeZoneName, falling back to UTC. Error: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
      timeZoneName = 'UTC';
    }
    debugPrint('Notification service initialized with timezone: $timeZoneName');

    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('launcher_icon');

    // iOS initialization
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // v17: initialize takes POSITIONAL argument for settings
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse response) async {
        // Handle notification tap here
      },
    );

    // Request Android permissions
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // v17: zonedSchedule takes POSITIONAL arguments for required fields
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Task reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // v17: named parameter `uiLocalNotificationDateInterpretation` remains
      // v17: named parameter `androidAllowWhileIdle` (replaced by `androidScheduleMode` in v18 check)
      // Actually v17.0.3 uses `androidScheduleMode`? Let's check. 
      // Docs say v17 introduced `androidScheduleMode`.
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    debugPrint('Scheduled notification for $title at $scheduledDate');
  }

  Future<void> cancelNotification(int id) async {
    // v17: cancel takes POSITIONAL argument for id
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
