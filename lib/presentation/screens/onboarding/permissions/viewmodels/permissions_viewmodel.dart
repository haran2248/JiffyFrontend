import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/permissions_state.dart';
import '../../../../../core/services/permission_service.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/services/service_providers.dart';
import '../../../../../core/services/waitlist_service.dart';
import '../../../../../core/auth/auth_viewmodel.dart';
import '../../../../../core/services/location_service.dart';

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
    // Clear any previous denied message so repeated taps trigger a fresh SnackBar
    final prevState = state.value ?? const PermissionsState();
    if (prevState.deniedMessage != null) {
      state = AsyncData(prevState.copyWith(clearDeniedMessage: true));
    }

    final result = await _permissionService.requestLocationPermission();
    final granted = result == PermissionResult.granted;
    debugPrint('Location permission result: $result');

    // If permission granted, immediately update location on backend
    if (granted) {
      try {
        final locationService = ref.read(locationServiceProvider);
        final locResult = await locationService.forceUpdateLocation();
        debugPrint(
            '[PermissionsViewModel] Location update complete. Result: $locResult');

        // Waitlist Check: Location Eligibility
        if (locResult == LocationUpdateResult.ineligible) {
          final waitlistService = ref.read(waitlistServiceProvider.notifier);
          final authState = ref.read(authViewModelProvider);
          final isCollege = waitlistService.isCollegeEmail(authState.email);

          // If they are not a college student (by email) AND location is ineligible,
          // they are waitlisted.
          if (!isCollege) {
            final currentState = state.value ?? const PermissionsState();

            // Notify backend about waitlist status
            if (authState.userId != null) {
              await ref
                  .read(waitlistServiceProvider.notifier)
                  .notifyWaitlisted(authState.userId!);
            }

            state = AsyncData(currentState.copyWith(
                isWaitlisted: true,
                locationGranted: true,
                clearDeniedMessage: true));
            return;
          }
        } else if (locResult == LocationUpdateResult.requestFailed) {
          debugPrint(
              '[PermissionsViewModel] Location update failed (network/backend error). '
              'Proceeding without waitlisting to allow retry.');
        }
      } catch (e) {
        debugPrint('[PermissionsViewModel] Error updating location: $e');
        // Don't fail permission grant if location update fails
      }

      final currentState = state.value ?? const PermissionsState();
      state = AsyncData(currentState.copyWith(
          locationGranted: true, clearDeniedMessage: true));
      return;
    }

    // Permission was denied
    final currentState = state.value ?? const PermissionsState();
    if (result == PermissionResult.permanentlyDenied) {
      // iOS won't show the system dialog again. Inform the user and let
      // them go to Settings voluntarily (Apple allows this for required features).
      state = AsyncData(currentState.copyWith(
        locationGranted: false,
        isPermanentlyDenied: true,
        deniedMessage:
            'Location access is required for finding matches. Please enable it in Settings.',
      ));
    } else {
      // First-time denial — show a simple toast
      state = AsyncData(currentState.copyWith(
        locationGranted: false,
        deniedMessage:
            'Location access is required for finding matches nearby.',
      ));
    }
  }

  Future<void> requestNotifications() async {
    // Clear previous message
    final prevState = state.value ?? const PermissionsState();
    if (prevState.deniedMessage != null) {
      state = AsyncData(prevState.copyWith(clearDeniedMessage: true));
    }

    PermissionResult result = PermissionResult.denied;
    try {
      // Use native permission handler to easily detect permanently denied status
      result = await _permissionService.requestNotificationPermission();
      
      // If granted, let Firebase also do its setup (alert/badge/sound options)
      if (result == PermissionResult.granted) {
        await _notificationService.requestPermissions();
      }
    } catch (e) {
      debugPrint('Notification request failed: $e');
    }

    final granted = result == PermissionResult.granted;
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
      
      final currentState = state.value ?? const PermissionsState();
      state = AsyncData(currentState.copyWith(notificationsGranted: true));
      return;
    }

    // Permission was denied
    final currentState = state.value ?? const PermissionsState();
    if (result == PermissionResult.permanentlyDenied) {
      state = AsyncData(currentState.copyWith(
        notificationsGranted: false,
        isPermanentlyDenied: true,
        deniedMessage:
            'Push notifications are disabled. Please enable them in Settings to stay updated on matches.',
      ));
    } else {
      state = AsyncData(currentState.copyWith(
        notificationsGranted: false,
        deniedMessage:
            'Enable notifications to never miss a match or message.',
      ));
    }
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
    // Clear previous message
    final prevState = state.value ?? const PermissionsState();
    if (prevState.deniedMessage != null) {
      state = AsyncData(prevState.copyWith(clearDeniedMessage: true));
    }

    final result = await _permissionService.requestCameraPermission();
    final granted = result == PermissionResult.granted;
    debugPrint('Camera permission status: ${granted ? 'Granted' : 'Denied'}');
    
    if (granted) {
      final currentState = state.value ?? const PermissionsState();
      state = AsyncData(currentState.copyWith(cameraGranted: true));
      return;
    }

    // Permission was denied
    final currentState = state.value ?? const PermissionsState();
    if (result == PermissionResult.permanentlyDenied) {
      state = AsyncData(currentState.copyWith(
        cameraGranted: false,
        isPermanentlyDenied: true,
        deniedMessage:
            'Camera access is disabled. Please enable it in Settings to take photos for your profile.',
      ));
    } else {
      state = AsyncData(currentState.copyWith(
        cameraGranted: false,
        deniedMessage:
            'Camera access is needed to take a profile picture.',
      ));
    }
  }

  /// Re-check all permission statuses from the OS.
  /// Called when the app resumes (e.g. user returns from Settings).
  Future<void> refreshPermissions() async {
    final locationStatus = await _permissionService.checkLocationStatus();
    final notificationStatus =
        await _permissionService.checkNotificationStatus();
    final cameraStatus = await _permissionService.checkCameraStatus();

    final currentState = state.value ?? const PermissionsState();

    // Only update if something actually changed
    if (currentState.locationGranted != locationStatus ||
        currentState.notificationsGranted != notificationStatus ||
        currentState.cameraGranted != cameraStatus) {
      debugPrint(
          '[PermissionsViewModel] Permissions refreshed — location: $locationStatus, '
          'notifications: $notificationStatus, camera: $cameraStatus');

      state = AsyncData(currentState.copyWith(
        locationGranted: locationStatus,
        notificationsGranted: notificationStatus,
        cameraGranted: cameraStatus,
        clearDeniedMessage: locationStatus || notificationStatus,
        isPermanentlyDenied: (locationStatus && notificationStatus) ? false : null,
      ));

      // If location was just granted via Settings, update backend
      if (locationStatus && !currentState.locationGranted) {
        try {
          final locationService = ref.read(locationServiceProvider);
          await locationService.forceUpdateLocation();
        } catch (e) {
          debugPrint(
              '[PermissionsViewModel] Error updating location after Settings: $e');
        }
      }
    }
  }

  void skip() {
    // Handle skipping or continuing
  }
}
