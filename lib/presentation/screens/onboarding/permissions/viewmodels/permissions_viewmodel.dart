import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/permissions_state.dart';
import '../../../../../core/services/permission_service.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/services/service_providers.dart';

part 'permissions_viewmodel.g.dart';

@riverpod
class PermissionsViewModel extends _$PermissionsViewModel {
  PermissionService get _permissionService =>
      ref.read(permissionServiceProvider);
  NotificationService get _notificationService =>
      ref.read(notificationServiceProvider);

  @override
  PermissionsState build() {
    _checkInitialStatus();
    return const PermissionsState();
  }

  Future<void> _checkInitialStatus() async {
    final locationStatus = await _permissionService.checkLocationStatus();
    final notificationStatus =
        await _permissionService.checkNotificationStatus();
    state = state.copyWith(
      locationGranted: locationStatus,
      notificationsGranted: notificationStatus,
    );
  }

  Future<void> requestLocation() async {
    final granted = await _permissionService.requestLocationPermission();
    debugPrint('Location permission status: ${granted ? 'Granted' : 'Denied'}');
    state = state.copyWith(locationGranted: granted);
  }

  Future<void> requestNotifications() async {
    // Both permission_handler and firebase_messaging can request this.
    // We use NotificationService for FCM specific settings.
    try {
      await _notificationService.requestPermissions();
    } catch (e) {
      debugPrint('Firebase Notification request failed: $e');
      // If Firebase fails, we fallback to native permission_handler to at least get the prompt
      await _permissionService.requestNotificationPermission();
    }

    final granted = await _permissionService.checkNotificationStatus();
    debugPrint(
        'Notification permission status: ${granted ? 'Granted' : 'Denied'}');

    if (granted) {
      try {
        final token = await _notificationService.getToken();
        if (token != null) {
          debugPrint('FCM Token successfully retrieved and uploading...');
          await _notificationService.uploadToken(token);
        }
      } catch (e) {
        debugPrint('FCM token retrieval failed: $e');
      }
    }

    state = state.copyWith(notificationsGranted: granted);
  }

  void skip() {
    // Handle skipping or continuing
  }
}
