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

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
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

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception(
            "Failed to save desired qualities: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            "Failed to save desired qualities: ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        throw Exception("Network error saving desired qualities: ${e.message}");
      }
    } catch (e) {
      throw Exception("Error saving desired qualities: $e");
    }
  }

  /// Initialize onboarding and get first 3 questions
  /// Endpoint: POST /api/onboarding/context
  /// Returns: List of 3 questions
  Future<List<String>> initializeOnboarding(
      Map<String, String> predefinedAnswers) async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final uid = user.uid;
      final response = await _dio.post(
        '/api/onboarding/context',
        data: {
          'uid': uid,
          'predefinedAnswers': predefinedAnswers,
        },
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception(
            "Failed to initialize onboarding: ${response.statusCode}");
      }

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (!success) {
        throw Exception(
            data['message'] as String? ?? "Failed to initialize onboarding");
      }

      final questions = (data['questions'] as List<dynamic>?)
              ?.map((q) => q.toString())
              .toList() ??
          [];

      return questions;
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        final message = errorData?['message'] as String? ??
            "Failed to initialize onboarding";
        throw Exception("$message (${e.response?.statusCode})");
      } else {
        throw Exception("Network error initializing onboarding: ${e.message}");
      }
    } catch (e) {
      throw Exception("Error initializing onboarding: $e");
    }
  }

  /// Submit answers and get next questions (if available)
  /// Endpoint: POST /api/onboarding/answers
  /// Returns: Next questions list (empty if complete) and completion status
  Future<Map<String, dynamic>> submitAnswers(
      List<String> questions, List<String> answers) async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final uid = user.uid;
      final response = await _dio.post(
        '/api/onboarding/answers',
        data: {
          'uid': uid,
          'questions': questions,
          'answers': answers,
        },
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception("Failed to submit answers: ${response.statusCode}");
      }

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (!success) {
        throw Exception(
            data['message'] as String? ?? "Failed to submit answers");
      }

      final nextQuestions = (data['nextQuestions'] as List<dynamic>?)
              ?.map((q) => q.toString())
              .toList() ??
          [];

      // Handle both "complete" and "isComplete" field names from backend
      final isComplete = (data['isComplete'] as bool?) ??
          (data['complete'] as bool?) ??
          false; // Default to false (more questions might come)

      return {
        'nextQuestions': nextQuestions,
        'isComplete': isComplete,
      };
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        final message =
            errorData?['message'] as String? ?? "Failed to submit answers";
        throw Exception("$message (${e.response?.statusCode})");
      } else {
        throw Exception("Network error submitting answers: ${e.message}");
      }
    } catch (e) {
      throw Exception("Error submitting answers: $e");
    }
  }
}
