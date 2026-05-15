import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/app_notification.dart';

class LocalNotificationsService {
  static const AndroidNotificationChannel _appointmentsChannel =
      AndroidNotificationChannel(
        'appointments_updates',
        'Appointment updates',
        description: 'Realtime appointment changes and reminders.',
        importance: Importance.high,
      );

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      ),
    );

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.createNotificationChannel(
      _appointmentsChannel,
    );
    await androidImplementation?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  static Future<void> show(AppNotification notification) async {
    await initialize();

    await _plugin.show(
      id: notification.createdAt.millisecondsSinceEpoch.remainder(1 << 31),
      title: notification.title,
      body: notification.message,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _appointmentsChannel.id,
          _appointmentsChannel.name,
          channelDescription: _appointmentsChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
