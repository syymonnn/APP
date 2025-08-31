import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/habit.dart';

/// A service to handle notification initialization, permission requests,
/// and scheduling of habit reminders.
class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service. Should be called in main().
  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    // For simplicity, set local location to device timezone; fallback to Europe/Rome
    try {
      final String localName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(_guessTzName(localName)));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Rome'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Request the necessary notification permissions (iOS & Android 13+)
  Future<void> requestPermissions() async {
    // iOS permissions
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    // Android 13+: POST_NOTIFICATIONS permission is requested by permission_handler
  }

  /// Schedule a daily notification for a habit. Uses times in HH:mm format.
  Future<void> scheduleDailyNotification(Habit habit, int id) async {
    if (!habit.notify) return;
    final now = tz.TZDateTime.now(tz.local);
    final parts = habit.notificationTime.split(':');
    final int hh = int.parse(parts[0]);
    final int mm = int.parse(parts[1]);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hh, mm);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    const androidDetails = AndroidNotificationDetails(
      'aeh_channel',
      'Æ‑HUMAN Notifications',
      channelDescription: 'Reminders for your habits',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      habit.title,
      'È ora di completare: ${habit.title}',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel a scheduled notification
  Future<void> cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Send a random motivational notification (placeholder). This could be
  /// improved to pull from a server or algorithm.
  Future<void> sendMotivationalQuote(String quote) async {
    final now = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
    const androidDetails = AndroidNotificationDetails(
      'aeh_motivational',
      'Motivational Quotes',
      channelDescription: 'Daily motivational messages',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      999,
      'Motivazione Æ',
      quote,
      now,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// A simple timezone name guesser. Extend this mapping for more locales.
  String _guessTzName(String osName) {
    // For Italy we use Europe/Rome; return as default.
    return 'Europe/Rome';
  }
}