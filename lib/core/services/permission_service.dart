import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of a permission request, distinguishing between
/// a first-time denial and a permanent denial (iOS won't show the dialog again).
enum PermissionResult {
  granted,
  denied,
  permanentlyDenied,
}

class PermissionService {
  Future<PermissionResult> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    debugPrint(
        '[PermissionService] Location permission status: ${status.toString()}');

    if (status.isGranted) return PermissionResult.granted;
    if (status.isPermanentlyDenied) return PermissionResult.permanentlyDenied;
    return PermissionResult.denied;
  }

  Future<bool> checkLocationStatus() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  Future<bool> isLocationPermanentlyDenied() async {
    return await Permission.locationWhenInUse.isPermanentlyDenied;
  }

  Future<PermissionResult> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    debugPrint(
        '[PermissionService] Notification permission status: ${status.toString()}');

    if (status.isGranted) return PermissionResult.granted;
    if (status.isPermanentlyDenied) return PermissionResult.permanentlyDenied;
    return PermissionResult.denied;
  }

  Future<bool> checkNotificationStatus() async {
    return await Permission.notification.isGranted;
  }

  Future<bool> requestPhotoLibraryPermission() async {
    final status = await Permission.photos.request();
    debugPrint(
        '[PermissionService] Photo library permission status: ${status.toString()}');

    // On iOS, both granted and limited permissions allow image picking
    // Treat limited as granted for our purposes
    return status.isGranted || status.isLimited;
  }

  Future<bool> checkPhotoLibraryStatus() async {
    final status = await Permission.photos.status;
    // On iOS, both granted and limited permissions allow image picking
    // Treat limited as granted for our purposes
    return status.isGranted || status.isLimited;
  }

  Future<PermissionResult> requestCameraPermission() async {
    final status = await Permission.camera.request();
    debugPrint(
        '[PermissionService] Camera permission status: ${status.toString()}');

    if (status.isGranted) return PermissionResult.granted;
    if (status.isPermanentlyDenied) return PermissionResult.permanentlyDenied;
    return PermissionResult.denied;
  }

  Future<bool> checkCameraStatus() async {
    return await Permission.camera.isGranted;
  }
}
