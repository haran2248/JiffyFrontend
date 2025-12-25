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
}
