import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'home_service.dart';
import 'permission_service.dart';
import 'notification_service.dart';
import 'profile_service.dart';

part 'service_providers.g.dart';

@riverpod
HomeService homeService(Ref ref) {
  return HomeService();
}

@riverpod
PermissionService permissionService(Ref ref) {
  return PermissionService();
}

@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

@riverpod
ProfileService profileService(Ref ref) {
  return ProfileService();
}
