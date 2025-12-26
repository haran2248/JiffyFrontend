import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  FirebaseMessaging get _messaging {
    if (Firebase.apps.isEmpty) {
      debugPrint(
          'ERROR: Firebase not initialized. Ensure Firebase.initializeApp() is called before accessing NotificationService.');
      throw StateError(
          'Firebase must be initialized before using NotificationService');
    }
    return FirebaseMessaging.instance;
  }

  Future<void> initialize() async {
    try {
      // Set up foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint(
              'Message also contained a notification: ${message.notification}');
        }
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Error initializing Notifications: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      rethrow;
    }
  }

  Future<void> uploadToken(String token) async {
    // TODO: Implement API call to upload token to backend
    debugPrint('Uploading token to backend: $token');
  }
}

// Global background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background tasks if needed
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}
