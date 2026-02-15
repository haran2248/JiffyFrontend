import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<bool> checkLocationStatus() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> checkNotificationStatus() async {
    return await Permission.notification.isGranted;
  }

  Future<bool> requestPhotoLibraryPermission() async {
    // Just request - let the system show the dialog. Only open settings if permanently denied.
    final status = await Permission.photos.request();
    debugPrint(
        '[PermissionService] Photo library permission status: ${status.toString()}');

    // Only open settings if permanently denied
    if (status.isPermanentlyDenied) {
      debugPrint(
          '[PermissionService] Photo library permanently denied, opening settings');
      await openAppSettings();
    }

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

  Future<bool> requestCameraPermission() async {
    // Just request - let the system show the dialog. Only open settings if permanently denied.
    final status = await Permission.camera.request();
    debugPrint(
        '[PermissionService] Camera permission status: ${status.toString()}');

    // Only open settings if permanently denied
    if (status.isPermanentlyDenied) {
      debugPrint(
          '[PermissionService] Camera permanently denied, opening settings');
      await openAppSettings();
    }

    return status.isGranted;
  }

  Future<bool> checkCameraStatus() async {
    return await Permission.camera.isGranted;
  }
}
