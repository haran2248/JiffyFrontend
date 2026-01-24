import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/auth/auth_repository.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/basic_details.dart';
import '../models/curated_profile.dart';
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

  /// Uploads profile image to the server.
  /// Endpoint: POST /api/users/uploadImages (Index 1)
  ///           POST /api/users/uploadSecondImage (Index 2)
  ///           POST /api/users/uploadThirdImage (Index 3)
  ///           POST /api/users/uploadFourthImage (Index 4)
  /// [imagePath] - Local file path of the image to upload
  /// [index] - Image index (1-4), defaults to 1
  /// [name] - User's display name (optional)
  Future<void> uploadProfileImage(String imagePath,
      {int index = 1, String? name}) async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final uid = user.uid;

      // Map index to endpoint
      String endpoint;
      switch (index) {
        case 1:
          endpoint = '/api/users/uploadImages';
          break;
        case 2:
          endpoint = '/api/users/uploadSecondImage';
          break;
        case 3:
          endpoint = '/api/users/uploadThirdImage';
          break;
        case 4:
          endpoint = '/api/users/uploadFourthImage';
          break;
        default:
          throw Exception("Invalid image index: $index. Must be 1-4.");
      }

      final formData = FormData.fromMap({
        'uid': uid,
        if (name != null) 'name': name,
        'images': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception(
            "Failed to upload profile image ($index): ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            "Failed to upload profile image ($index): ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        throw Exception(
            "Network error uploading profile image ($index): ${e.message}");
      }
    } catch (e) {
      throw Exception("Error uploading profile image ($index): $e");
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

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
      }

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
        final errorData = e.response?.data;
        final message = (errorData is Map<String, dynamic>)
            ? (errorData['message'] as String? ??
                "Failed to initialize onboarding")
            : "Failed to initialize onboarding";
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

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
      }

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
        final errorData = e.response?.data;
        final message = (errorData is Map<String, dynamic>)
            ? (errorData['message'] as String? ?? "Failed to submit answers")
            : "Failed to submit answers";
        throw Exception("$message (${e.response?.statusCode})");
      } else {
        throw Exception("Network error submitting answers: ${e.message}");
      }
    } catch (e) {
      throw Exception("Error submitting answers: $e");
    }
  }

  /// Generate curated profile from AI analysis of Q&A
  /// Endpoint: POST /api/onboarding/curated-profile/generate
  Future<CuratedProfile> generateCuratedProfile() async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final uid = user.uid;
      final response = await _dio.post(
        '/api/onboarding/curated-profile/generate',
        queryParameters: {'uid': uid},
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception(
            "Failed to generate curated profile: ${response.statusCode}");
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
      }

      final success = data['success'] as bool? ?? false;
      if (!success) {
        throw Exception(
            data['message'] as String? ?? "Failed to generate curated profile");
      }

      final curatedProfileData =
          data['curatedProfile'] as Map<String, dynamic>?;
      if (curatedProfileData == null) {
        throw Exception("No curated profile data returned");
      }

      return CuratedProfile.fromJson(curatedProfileData);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        final message = (errorData is Map<String, dynamic>)
            ? (errorData['message'] as String? ??
                "Failed to generate curated profile")
            : "Failed to generate curated profile";
        throw Exception("$message (${e.response?.statusCode})");
      } else {
        throw Exception(
            "Network error generating curated profile: ${e.message}");
      }
    } catch (e) {
      throw Exception("Error generating curated profile: $e");
    }
  }

  /// Get existing curated profile
  /// Endpoint: GET /api/onboarding/curated-profile
  Future<CuratedProfile?> getCuratedProfile() async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final uid = user.uid;
      final response = await _dio.get(
        '/api/onboarding/curated-profile',
        queryParameters: {'uid': uid},
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception(
            "Failed to get curated profile: ${response.statusCode}");
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
      }

      final curatedProfileData =
          data['curatedProfile'] as Map<String, dynamic>?;
      if (curatedProfileData == null) {
        return null;
      }

      return CuratedProfile.fromJson(curatedProfileData);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            "Failed to get curated profile: ${e.response?.statusCode}");
      } else {
        throw Exception("Network error getting curated profile: ${e.message}");
      }
    } catch (e) {
      throw Exception("Error getting curated profile: $e");
    }
  }

  /// Update curated profile (for user edits)
  /// Endpoint: PUT /api/onboarding/curated-profile
  Future<CuratedProfile> updateCuratedProfile(CuratedProfile profile) async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final uid = user.uid;
      final response = await _dio.put(
        '/api/onboarding/curated-profile',
        data: profile.toJson(),
        queryParameters: {'uid': uid},
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception(
            "Failed to update curated profile: ${response.statusCode}");
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
      }

      final curatedProfileData =
          data['curatedProfile'] as Map<String, dynamic>?;
      if (curatedProfileData == null) {
        throw Exception("No curated profile data returned");
      }

      return CuratedProfile.fromJson(curatedProfileData);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        final message = (errorData is Map<String, dynamic>)
            ? (errorData['message'] as String? ??
                "Failed to update curated profile")
            : "Failed to update curated profile";
        throw Exception("$message (${e.response?.statusCode})");
      } else {
        throw Exception("Network error updating curated profile: ${e.message}");
      }
    } catch (e) {
      throw Exception("Error updating curated profile: $e");
    }
  }
}
