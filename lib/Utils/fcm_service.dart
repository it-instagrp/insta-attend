import 'dart:io'; // Add this import
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<String?> getFCMToken() async {
    try {
      // 1. Request permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. For iOS, wait for APNS token to be available
        if (Platform.isIOS) {
          String? apnsToken = await _messaging.getAPNSToken();
          if (apnsToken == null) {
            log("APNS token not yet available. Retrying...");
            // Optional: Wait a moment or handle retry logic
            await Future.delayed(const Duration(seconds: 2));
            apnsToken = await _messaging.getAPNSToken();
          }
        }

        // 3. Now retrieve the FCM token
        String? token = await _messaging.getToken();
        log("FCM Token: $token");
        return token;
      } else {
        log("User declined notification permissions");
        return null;
      }
    } catch (e) {
      log("Error fetching FCM token: $e");
      return null;
    }
  }
}