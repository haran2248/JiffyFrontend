import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/auth/auth_repository.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/basic_details.dart';
import '../models/desired_qualities.dart';

part 'onboarding_repository.g.dart';

@riverpod
OnboardingRepository onboardingRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return OnboardingRepository(dio, authRepo);
}

class OnboardingRepository {
  final Dio _dio;
  final AuthRepository _authRepo;

  OnboardingRepository(this._dio, this._authRepo);

  /// Saves basic user details including preferred gender.
  /// Endpoint: POST /userInformation
  Future<void> saveUserInformation(BasicDetails details) async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final uid = user.uid;
      final response = await _dio.post(
        '/api/users/userInformation',
        data: details.toJson(),
        queryParameters: {'uid': uid},
      );

      if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
        throw Exception(
            "Failed to save user information: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            "Failed to save user information: ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        throw Exception("Network error saving user information: ${e.message}");
      }
    } catch (e) {
      throw Exception("Error saving user information: $e");
    }
  }

  /// Saves desired qualities including relationship goals.
  /// Endpoint: POST /desiredQualities
  Future<void> saveDesiredQualities(DesiredQualities qualities) async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final uid = user.uid;
      final response = await _dio.post(
        '/api/users/desiredQualities',
        data: qualities.toJson(),
        queryParameters: {'uid': uid},
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
            "Failed to save desired qualities: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error saving desired qualities: $e");
    }
  }
}
