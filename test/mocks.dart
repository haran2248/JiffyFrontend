import 'package:jiffy/core/services/permission_service.dart';
import 'package:jiffy/core/services/notification_service.dart';

class MockPermissionService implements PermissionService {
  @override
  Future<bool> checkLocationStatus() async => false;
  @override
  Future<bool> checkNotificationStatus() async => false;
  @override
  Future<bool> requestLocationPermission() async => true;
  @override
  Future<bool> requestNotificationPermission() async => true;
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
