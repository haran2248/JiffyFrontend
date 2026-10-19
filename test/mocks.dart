import 'package:jiffy/core/services/permission_service.dart';
import 'package:jiffy/core/services/notification_service.dart';

class MockPermissionService implements PermissionService {
  bool _locationGranted = false;
  bool _notificationGranted = false;

  @override
  Future<bool> checkLocationStatus() async => _locationGranted;

  @override
  Future<bool> isLocationPermanentlyDenied() async => false;

  @override
  Future<bool> checkNotificationStatus() async => _notificationGranted;

  @override
  Future<PermissionResult> requestLocationPermission() async {
    _locationGranted = true;
    return PermissionResult.granted;
  }

  @override
  Future<PermissionResult> requestNotificationPermission() async {
    _notificationGranted = true;
    return PermissionResult.granted;
  }

  @override
  Future<PermissionResult> requestCameraPermission() async =>
      PermissionResult.granted;

  @override
  Future<bool> checkCameraStatus() async => true;

  @override
  Future<bool> requestPhotoLibraryPermission() async => true;

  @override
  Future<bool> checkPhotoLibraryStatus() async => true;
}

class MockNotificationService implements NotificationService {
  @override
  void Function(Map<String, dynamic> data)? onNotificationTap;

  @override
  Future<void> initialize() async {}
  @override
  Future<String?> getToken() async => "mock-token";
  @override
  Future<bool> requestPermissions() async => true;
  @override
  Future<void> uploadToken(String token) async {}
  @override
  Future<void> registerForPushNotifications() async {}
}
