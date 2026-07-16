import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// The seam between the app and the platform notification system.
///
/// The state layer depends only on this interface, never on a concrete plugin.
/// Today it's backed by [LocalNotificationService] (on-device local
/// notifications). When a backend with push lands, a `PushNotificationService`
/// can implement the same interface for server-driven alerts (new certs, exam
/// reminders) without touching the UI or app state.
abstract class NotificationService {
  /// Must be awaited once at startup before any scheduling call.
  Future<void> init();

  /// Ask the OS for permission to post notifications. Returns whether it was
  /// granted. Safe to call repeatedly — the OS only prompts once.
  Future<bool> requestPermission();

  /// Schedule (or replace) the daily study reminder at [time]. Repeats every
  /// day at the same local wall-clock time.
  Future<void> scheduleDailyReminder(TimeOfDay time);

  /// Cancel the daily study reminder if one is scheduled.
  Future<void> cancelDailyReminder();
}

/// Local-notification implementation backed by `flutter_local_notifications`.
///
/// Only the daily study reminder is wired here because it's the one reminder
/// with a purely on-device trigger. "New certification" and "exam" alerts
/// depend on server events / exam data that don't exist locally yet, so those
/// toggles are persisted for when a push backend lands.
class LocalNotificationService implements NotificationService {
  static const int _dailyReminderId = 1001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// The platforms where local notifications are wired. The app's real targets
  /// are Android and iOS; guarding here keeps `init()` from throwing on desktop
  /// debug runs where the plugin isn't configured.
  bool get _supported => Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  @override
  Future<void> init() async {
    if (_initialized || !_supported) return;

    // Resolve the device's timezone so the daily reminder fires at the local
    // wall-clock time the user picked, not UTC.
    tz.initializeTimeZones();
    try {
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (_) {
      // Fall back to UTC if the platform can't report a timezone. The reminder
      // still fires, just anchored to UTC.
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // Permissions are requested explicitly via [requestPermission], not at init.
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      ),
    );

    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    if (!_supported) return false;
    await init();

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      // Android 13+ requires an explicit runtime notification permission.
      final granted = await android.requestNotificationsPermission();
      // Android 12+ gates exact alarms behind a separate grant. USE_EXACT_ALARM
      // covers most devices; this asks for the SCHEDULE_EXACT_ALARM fallback so
      // the reminder still fires at the exact time where that's needed.
      await android.requestExactAlarmsPermission();
      return granted ?? true;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    if (macos != null) {
      final granted = await macos.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    if (!_supported) return;
    await init();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'study_reminders',
        'Study reminders',
        channelDescription: 'Your daily nudge to keep your streak going.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    // Replace any existing schedule so changing the time doesn't stack.
    await _plugin.cancel(_dailyReminderId);

    // Prefer an exact alarm so the reminder lands at the chosen minute. If the
    // device hasn't granted the exact-alarm permission, the plugin throws
    // 'exact_alarms_not_permitted' — fall back to an inexact alarm (fires
    // approximately, but at least fires) rather than dropping the reminder.
    try {
      await _schedule(time, details, AndroidScheduleMode.exactAllowWhileIdle);
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        await _schedule(time, details, AndroidScheduleMode.inexactAllowWhileIdle);
      } else {
        rethrow;
      }
    }
  }

  Future<void> _schedule(
    TimeOfDay time,
    NotificationDetails details,
    AndroidScheduleMode mode,
  ) {
    return _plugin.zonedSchedule(
      _dailyReminderId,
      'Time to study',
      "A few minutes today keeps your certification on track.",
      _nextInstanceOf(time),
      details,
      androidScheduleMode: mode,
      // Required by flutter_local_notifications < 19: the picked time is a
      // wall-clock time, so interpret it as an absolute point, not elapsed.
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // Repeat daily at the same wall-clock time.
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelDailyReminder() async {
    if (!_supported) return;
    await init();
    await _plugin.cancel(_dailyReminderId);
  }

  /// The next occurrence of [time] in local time, today if it's still ahead,
  /// otherwise tomorrow.
  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
