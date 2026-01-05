import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/auth/auth_repository.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import 'package:jiffy/core/network/errors/api_error.dart';
import 'package:jiffy/presentation/screens/stories/data/stories_api_endpoints.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stories_repository.g.dart';

@riverpod
StoriesRepository storiesRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return StoriesRepository(dio, authRepo);
}

/// Repository for stories-related API operations.
class StoriesRepository {
  final Dio _dio;
  final AuthRepository _authRepo;

  StoriesRepository(this._dio, this._authRepo);

  /// Fetch user's own stories.
  ///
  /// Returns a list of stories for the current user.
  /// Throws [ApiError] on failure.
  Future<List<Map<String, dynamic>>> fetchUserStories() async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) {
        throw ApiError.unknown(
          message: 'User not authenticated',
          requestPath: StoriesApiEndpoints.myStories,
        );
      }

      final userId = user.uid;

      // API expects userId as query parameter for GET request
      final response = await _dio.get(
        StoriesApiEndpoints.myStories,
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        }
        throw ApiError.unknown(
          message: 'Invalid response format',
          requestPath: StoriesApiEndpoints.myStories,
        );
      } else {
        throw ApiError.unknown(
          message: 'Failed to fetch user stories: ${response.statusCode}',
          requestPath: StoriesApiEndpoints.myStories,
        );
      }
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError.unknown(
        message: 'Failed to fetch user stories',
        originalError: e,
        requestPath: StoriesApiEndpoints.myStories,
      );
    }
  }

  /// Fetch stories for matched users.
  ///
  /// Returns a list of stories from matched users.
  /// Throws [ApiError] on failure.
  Future<List<Map<String, dynamic>>> fetchStories() async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) {
        throw ApiError.unknown(
          message: 'User not authenticated',
          requestPath: StoriesApiEndpoints.matches,
        );
      }

      final userId = user.uid;

      // API expects userId as query parameter for GET request
      final response = await _dio.get(
        StoriesApiEndpoints.matches,
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        }
        throw ApiError.unknown(
          message: 'Invalid response format',
          requestPath: StoriesApiEndpoints.matches,
        );
      } else {
        throw ApiError.unknown(
          message: 'Failed to fetch stories: ${response.statusCode}',
          requestPath: StoriesApiEndpoints.matches,
        );
      }
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError.unknown(
        message: 'Failed to fetch stories',
        originalError: e,
        requestPath: StoriesApiEndpoints.matches,
      );
    }
  }

  /// Upload a story image.
  ///
  /// [imageFile] - The image file to upload
  /// [mediaType] - Type of media (e.g., "IMAGE")
  ///
  /// Throws [ApiError] on failure.
  Future<void> uploadStory({
    required File imageFile,
    String mediaType = 'IMAGE',
  }) async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) {
        throw ApiError.unknown(
          message: 'User not authenticated',
          requestPath: StoriesApiEndpoints.upload,
        );
      }

      final userId = user.uid;

      // Create multipart form data
      final formData = FormData.fromMap({
        'userId': userId,
        'mediaType': mediaType,
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        StoriesApiEndpoints.upload,
        data: formData,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        // Success
        return;
      } else {
        throw ApiError.unknown(
          message: 'Failed to upload story: ${response.statusCode}',
          requestPath: StoriesApiEndpoints.upload,
        );
      }
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError.unknown(
        message: 'Failed to upload story',
        originalError: e,
        requestPath: StoriesApiEndpoints.upload,
      );
    }
  }
}

