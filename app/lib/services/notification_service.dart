import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules the on-device study reminder promised by the Notifications
/// screen. Purely local — no server or push involved, so this is the seam
/// for the "study reminders" toggle only.
class NotificationService {
  static const _studyReminderId = 100;
  static const _channelId = 'study_reminders';
  static const _channelName = 'Study reminders';

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    // Permission requests are deferred to [requestPermission], fired only
    // when the user turns the toggle on — not silently at every app launch.
    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ));
    _initialized = true;
  }

  /// Requests OS notification permission. Returns whether it was granted.
  Future<bool> requestPermission() async {
    await _ensureInitialized();

    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }

    return true;
  }

  /// (Re)schedules the daily study reminder at [time], replacing any
  /// previously scheduled one. Assumes permission was already granted.
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await _ensureInitialized();
    await _plugin.zonedSchedule(
      _studyReminderId,
      'Time to study',
      "Keep your streak going — pick up your lesson where you left off.",
      _nextInstanceOf(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Your daily study reminder.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    await _ensureInitialized();
    await _plugin.cancel(_studyReminderId);
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
