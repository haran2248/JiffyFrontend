import 'package:jiffy/core/services/permission_service.dart';
import 'package:jiffy/core/services/notification_service.dart';

class MockPermissionService implements PermissionService {
  bool _locationGranted = false;
  bool _notificationGranted = false;

  @override
  Future<bool> checkLocationStatus() async => _locationGranted;
  @override
  Future<bool> checkNotificationStatus() async => _notificationGranted;
  @override
  Future<bool> requestLocationPermission() async {
    _locationGranted = true;
    return true;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    _notificationGranted = true;
    return true;
  }

  @override
  Future<bool> requestPhotoLibraryPermission() async => true;

  @override
  Future<bool> checkPhotoLibraryStatus() async => true;

  @override
  Future<bool> requestCameraPermission() async => true;

  @override
  Future<bool> checkCameraStatus() async => true;
}

class MockNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> getToken() async => "mock-token";
  @override
  Future<void> requestPermissions() async {}
  @override
  Future<void> uploadToken(String token) async {}
}
