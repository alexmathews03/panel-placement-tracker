import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // Request Android 13+ permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Schedule a reminder [minutesBefore] before [targetDate].
  static Future<void> scheduleReminder({
    required int id,
    required String companyName,
    required String label,
    required DateTime targetDate,
    required int minutesBefore,
  }) async {
    await init();

    final scheduledTime = targetDate.subtract(Duration(minutes: minutesBefore));

    // Don't schedule if time has already passed
    if (scheduledTime.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'drivedeck_reminders',
      'Drive Reminders',
      channelDescription: 'Placement drive deadline & assessment reminders',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF7EF4FF),
      playSound: true,
      enableVibration: true,
    );

    const notifDetails = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      '📣 $companyName – $label',
      minutesBefore >= 1440
          ? '${minutesBefore ~/ 1440} day(s) until your placement drive.'
          : minutesBefore >= 60
              ? '${minutesBefore ~/ 60} hour(s) to go. Good luck!'
              : '$minutesBefore minutes left. You\'ve got this!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Fire an immediate test notification.
  static Future<void> showInstant({
    required String companyName,
    required String message,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'drivedeck_reminders',
      'Drive Reminders',
      channelDescription: 'Placement drive deadline & assessment reminders',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF7EF4FF),
    );

    await _plugin.show(
      0,
      '🔔 Reminder set for $companyName',
      message,
      const NotificationDetails(android: androidDetails),
    );
  }

  /// Cancel a specific scheduled notification.
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel ALL scheduled notifications.
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
