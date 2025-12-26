import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'permission_service.dart';
import 'notification_service.dart';

part 'service_providers.g.dart';

@riverpod
PermissionService permissionService(Ref ref) {
  return PermissionService();
}

@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}
