import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ✅ Initialize the notification system
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(initSettings);
    print("✅ NotificationService initialized.");
  }

  // ✅ Show a local notification
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'e_motawif_channel', // ✅ Channel ID
      'E-Motawif Notifications', // ✅ Channel name
      channelDescription:
          'Notifications for messages, health, and tracking alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );

    print("🔔 Notification shown → $title: $body");
  }
}
