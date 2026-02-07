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
  Future<PermissionsState> build() async {
    final locationStatus = await _permissionService.checkLocationStatus();
    final notificationStatus =
        await _permissionService.checkNotificationStatus();

    final cameraStatus = await _permissionService.checkCameraStatus();
    return PermissionsState(
      locationGranted: locationStatus,
      notificationsGranted: notificationStatus,
      cameraGranted: cameraStatus,
    );
  }

  Future<void> requestLocation() async {
    final granted = await _permissionService.requestLocationPermission();
    debugPrint('Location permission status: ${granted ? 'Granted' : 'Denied'}');

    // If permission granted, immediately update location on backend
    if (granted) {
      try {
        final locationService = ref.read(locationServiceProvider);
        debugPrint(
            '[PermissionsViewModel] Forcing location update after permission grant');
        await locationService.forceUpdateLocation();
        debugPrint('[PermissionsViewModel] Location update complete');
      } catch (e) {
        debugPrint('[PermissionsViewModel] Error updating location: $e');
        // Don't fail permission grant if location update fails
      }
    }

    final currentState = state.value ?? const PermissionsState();
    state = AsyncData(currentState.copyWith(locationGranted: granted));
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

    final currentState = state.value ?? const PermissionsState();
    state = AsyncData(currentState.copyWith(notificationsGranted: granted));
  }

  Future<void> requestPhotoLibrary() async {
    final granted = await _permissionService.requestPhotoLibraryPermission();
    debugPrint(
        'Photo library permission status: ${granted ? 'Granted (or Limited)' : 'Denied'}');
    final currentState = state.value ?? const PermissionsState();
    // Permission service already treats limited as granted
    state = AsyncData(currentState.copyWith(photoLibraryGranted: granted));
  }

  Future<void> requestCamera() async {
    final granted = await _permissionService.requestCameraPermission();
    debugPrint('Camera permission status: ${granted ? 'Granted' : 'Denied'}');
    final currentState = state.value ?? const PermissionsState();
    state = AsyncData(currentState.copyWith(cameraGranted: granted));
  }

  void skip() {
    // Handle skipping or continuing
  }
}
