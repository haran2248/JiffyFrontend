import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/network/dio_provider.dart';
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
  final dio = ref.watch(dioProvider);
  return HomeService(
    storiesRepository: storiesRepository,
    matchesRepository: matchesRepository,
    authRepository: authRepository,
    dio: dio,
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

@riverpod
PhotoUploadService photoUploadService(Ref ref) {
  return PhotoUploadService();
}
