import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/core/auth/auth_repository.dart';
import 'package:jiffy/presentation/screens/stories/data/stories_repository.dart';
import 'package:jiffy/presentation/screens/matches/data/matches_repository.dart';
import 'home_service.dart';
import 'permission_service.dart';
import 'notification_service.dart';
import 'profile_service.dart';
import 'photo_upload_service.dart';

part 'service_providers.g.dart';

@riverpod
HomeService homeService(Ref ref) {
  final storiesRepository = ref.watch(storiesRepositoryProvider);
  final matchesRepository = ref.watch(matchesRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return HomeService(
    storiesRepository: storiesRepository,
    matchesRepository: matchesRepository,
    authRepository: authRepository,
  );
}

@riverpod
PermissionService permissionService(Ref ref) {
  return PermissionService();
}

@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

// ProfileService is now defined in profile_service.dart with its own provider

@riverpod
PhotoUploadService photoUploadService(Ref ref) {
  return PhotoUploadService();
}
