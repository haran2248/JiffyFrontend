import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/dio_provider.dart';

part 'face_verification_service.g.dart';

/// API endpoints for face verification
class FaceVerificationEndpoints {
  static const String getIsVerified = '/api/users/getIsVerified';
  static const String setIsVerified = '/api/users/isVerified';
}

/// Service for face verification API calls
@riverpod
FaceVerificationService faceVerificationService(Ref ref) {
  return FaceVerificationService(ref.watch(dioProvider));
}

class FaceVerificationService {
  final Dio _dio;

  FaceVerificationService(this._dio);

  /// Check if user is verified
  ///
  /// Returns true if verified, false otherwise
  /// Returns false on error (safer to show verification than skip it)
  Future<bool> isUserVerified(String uid) async {
    try {
      final response = await _dio.get(
        FaceVerificationEndpoints.getIsVerified,
        queryParameters: {'uid': uid},
      );

      if (response.statusCode == 200) {
        // Handle both boolean and string responses
        final data = response.data;
        if (data is bool) return data;
        if (data is String) return data.toLowerCase() == 'true';
        return false;
      }
      return false;
    } catch (e) {
      debugPrint('FaceVerificationService: Error checking verification - $e');
      return false;
    }
  }

  /// Update user verification status
  ///
  /// Returns true on success, false on failure
  Future<bool> updateVerificationStatus(String uid, bool isVerified) async {
    try {
      final response = await _dio.post(
        FaceVerificationEndpoints.setIsVerified,
        queryParameters: {'uid': uid},
        data: {'isVerified': isVerified.toString()},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('FaceVerificationService: Error updating verification - $e');
      return false;
    }
  }
}
