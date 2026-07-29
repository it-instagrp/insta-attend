import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Fetch FCM Token safely with APNS handling for iOS
  static Future<String?> getFCMToken() async {
    try {
      // 1. Request notification permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {

        // 2. iOS specific: Wait for APNS token to be available
        if (Platform.isIOS) {
          String? apnsToken = await _messaging.getAPNSToken();
          int retryCount = 0;

          // Retry logic while waiting for APNS token
          while (apnsToken == null && retryCount < 3) {
            if (kDebugMode) {
              log("APNS token not available yet. Retrying (${retryCount + 1}/3)...");
            }
            await Future.delayed(const Duration(seconds: 2));
            apnsToken = await _messaging.getAPNSToken();
            retryCount++;
          }

          if (apnsToken == null) {
            debugPrint("APNS Token retrieval timed out.");
            return null;
          }
        }

        // 3. Retrieve FCM Token
        String? fcmToken = await _messaging.getToken();
        if (kDebugMode) {
          log("FCM Token retrieved successfully: $fcmToken");
        }
        return fcmToken;
      } else {
        if (kDebugMode) {
          log("Notification permission declined by user.");
        }
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching FCM token: $e");
      return null;
    }
  }

  /// Listen for FCM Token refresh events (useful for session synchronization)
  static StreamSubscription<String> listenToTokenRefresh(
      Function(String newToken) onTokenRefresh,
      ) {
    return _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        log("FCM Token Refreshed: $newToken");
      }
      onTokenRefresh(newToken);
    });
  }
}