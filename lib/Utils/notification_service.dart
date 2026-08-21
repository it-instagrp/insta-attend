import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings, // Fixed: Added named parameter 'settings:'
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        final String? payload = details.payload;
        if (payload != null && payload.isNotEmpty) {
          await OpenFilex.open(payload);
        }
      },
    );
  }

  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'insta_attend_channel',
      'High Importance Notifications',
      channelDescription: 'Channel for general app notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // Fixed: Added named parameters for id, title, body, notificationDetails
    await _notificationsPlugin.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: notificationDetails,
      payload: message.data['filePath'],
    );
  }

  static Future<void> showDownloadNotification({
    required String fileName,
    required String filePath,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'pdf_download_channel',
      'PDF Downloads',
      channelDescription: 'Notifications for generated PDF reports',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // Fixed: Added named parameters for id, title, body, notificationDetails
    await _notificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Download Complete',
      body: '$fileName saved successfully. Tap to view.',
      notificationDetails: notificationDetails,
      payload: filePath,
    );
  }
}