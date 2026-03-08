import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service for managing FCM push notifications.
///
/// Handles:
/// - Permission requests
/// - FCM token retrieval and upload to backend
/// - Token refresh monitoring
/// - Foreground/background/terminated message handling
/// - Notification tap routing
class NotificationService {
  final Dio _dio;

  /// Callback invoked when a user taps a notification.
  /// Receives the [RemoteMessage] data map for routing decisions.
  void Function(Map<String, dynamic> data)? onNotificationTap;

  NotificationService({required Dio dio}) : _dio = dio;

  FirebaseMessaging get _messaging {
    if (Firebase.apps.isEmpty) {
      debugPrint(
          'ERROR: Firebase not initialized. Ensure Firebase.initializeApp() is called before accessing NotificationService.');
      throw StateError(
          'Firebase must be initialized before using NotificationService');
    }
    return FirebaseMessaging.instance;
  }

  /// Full initialization — call once after user is authenticated.
  ///
  /// This sets up:
  /// 1. Foreground notification display options (iOS)
  /// 2. Foreground message listener
  /// 3. Notification tap handlers (background + terminated)
  /// 4. Token refresh listener
  Future<void> initialize() async {
    try {
      // Show notifications as banners even while app is in foreground (iOS)
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // FOREGROUND: App is open and visible
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM] Foreground message: ${message.messageId}');
        debugPrint('[FCM] Title: ${message.notification?.title}');
        debugPrint('[FCM] Body: ${message.notification?.body}');
        debugPrint('[FCM] Data: ${message.data}');
      });

      // BACKGROUND → TAP: App was in background, user tapped notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint(
            '[FCM] Notification tapped (from background): ${message.data}');
        onNotificationTap?.call(message.data);
      });

      // TERMINATED → TAP: App was killed, user tapped notification to open
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
            '[FCM] App opened from terminated via notification: ${initialMessage.data}');
        onNotificationTap?.call(initialMessage.data);
      }

      // Listen for token refresh — tokens rotate periodically
      _messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('[FCM] Token refreshed, uploading new token...');
        await uploadToken(newToken);
      });

      debugPrint('[FCM] NotificationService initialized');
    } catch (e) {
      debugPrint('[FCM] Error initializing NotificationService: $e');
    }
  }

  /// Request notification permission (shows iOS dialog).
  Future<bool> requestPermissions() async {
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

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized;
      debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
      return granted;
    } catch (e) {
      debugPrint('[FCM] Error requesting permissions: $e');
      rethrow;
    }
  }

  /// Get the FCM registration token.
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('[FCM] Token: $token');
      return token;
    } catch (e) {
      debugPrint('[FCM] Error getting token: $e');
      return null;
    }
  }

  /// Upload the FCM token to the SwishBackend.
  ///
  /// Sends a POST to `/api/user/device-token` with the current user's UID
  /// and the FCM registration token.
  Future<void> uploadToken(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[FCM] No authenticated user — skipping token upload');
        return;
      }

      debugPrint('[FCM] Uploading token to backend...');
      await _dio.post(
        '/api/user/device-token',
        queryParameters: {
          'uid': user.uid,
          'fcmToken': token,
        },
      );

      debugPrint('[FCM] Token uploaded for uid=${user.uid}');
    } catch (e) {
      debugPrint('[FCM] Error uploading token: $e');
      // Don't rethrow — token upload failure shouldn't crash the app
    }
  }

  /// Convenience: request permission → get token → upload to backend.
  ///
  /// Call this after the user authenticates.
  Future<void> registerForPushNotifications() async {
    final granted = await requestPermissions();
    if (!granted) {
      debugPrint('[FCM] User declined notifications');
      return;
    }

    final token = await getToken();
    if (token != null) {
      await uploadToken(token);
    }
  }
}

// ── Global background handler ──
// MUST be top-level, not a class method.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message: ${message.messageId}');
}
