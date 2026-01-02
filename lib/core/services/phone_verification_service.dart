import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/dio_provider.dart';
import '../network/errors/api_error.dart';
import '../../presentation/screens/phone_verification_ui/models/phone_verification_models.dart';

part 'phone_verification_service.g.dart';

/// Service for phone verification API calls.
///
/// Endpoints:
/// - POST /api/users/updatePhoneNumber - Send verification code
/// - POST /api/users/verifyOtp - Verify OTP code
/// - GET /api/users/getUser - Check verification status
@riverpod
PhoneVerificationService phoneVerificationService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return PhoneVerificationService(dio: dio);
}

class PhoneVerificationService {
  final Dio _dio;

  PhoneVerificationService({required Dio dio}) : _dio = dio;

  // ============================================================
  // PHONE VERIFICATION STATUS CHECK WITH CACHING
  // ============================================================
  //
  //
  // CURRENT CACHING IMPLEMENTATION:
  //    - Static in-memory cache shared across instances
  //    - Cleared after successful OTP verification
  //    - Force refresh option for explicit cache bypass
  // ============================================================

  /// In-memory cache for phone verification status.
  /// Key: uid, Value: isPhoneVerified
  static final Map<String, bool> _verificationCache = {};

  /// Check if user's phone is already verified.
  ///
  /// [uid] - User ID from Firebase Auth
  /// [forceRefresh] - If true, bypasses cache and fetches from server
  ///
  /// Returns true if phone is verified, false otherwise.
  /// On error, returns false (safer to re-verify than skip).
  Future<bool> isPhoneVerified({
    required String uid,
    bool forceRefresh = false,
  }) async {
    // Check cache first (unless force refresh)
    if (!forceRefresh && _verificationCache.containsKey(uid)) {
      debugPrint('PhoneVerificationService: Cache hit for uid=$uid');
      return _verificationCache[uid]!;
    }

    try {
      debugPrint('PhoneVerificationService: Fetching verification status');

      final response = await _dio.get(
        '/api/users/getUser',
        queryParameters: {'uid': uid},
      );

      final data = response.data as Map<String, dynamic>?;
      final isVerified = data?['isPhoneVerified'] == true;

      // Cache the result
      _verificationCache[uid] = isVerified;
      debugPrint('PhoneVerificationService: isPhoneVerified=$isVerified');

      return isVerified;
    } on DioException catch (e) {
      debugPrint('PhoneVerificationService: Error - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('PhoneVerificationService: Error - $e');
      return false;
    }
  }

  /// Clear the verification cache.
  static void clearCache([String? uid]) {
    if (uid != null) {
      _verificationCache.remove(uid);
    } else {
      _verificationCache.clear();
    }
  }

  /// Update cache after successful verification (optimistic update).
  static void markAsVerified(String uid) {
    _verificationCache[uid] = true;
  }

  /// Send verification code to a phone number.
  Future<PhoneVerificationResponse> sendVerificationCode({
    required String phoneNumber,
    required String uid,
  }) async {
    try {
      debugPrint('PhoneVerificationService: Sending OTP to $phoneNumber');

      final request = PhoneVerificationRequest(
        uid: uid,
        phoneNumber: phoneNumber,
      );

      final response = await _dio.post(
        '/api/users/updatePhoneNumber',
        data: request.toJson(),
      );

      final result = PhoneVerificationResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (result.isSuccess) {
        debugPrint('PhoneVerificationService: OTP sent successfully');
      } else {
        debugPrint('PhoneVerificationService: Failed - ${result.message}');
      }

      return result;
    } on DioException catch (e) {
      debugPrint('PhoneVerificationService: DioException - ${e.message}');

      if (e.error is ApiError) {
        final apiError = e.error as ApiError;
        return PhoneVerificationResponse.error(apiError.message);
      }

      if (e.response?.data != null) {
        try {
          return PhoneVerificationResponse.fromJson(
            e.response!.data as Map<String, dynamic>,
          );
        } catch (_) {}
      }

      return PhoneVerificationResponse.error(
        e.message ?? 'Failed to send verification code',
      );
    } catch (e) {
      debugPrint('PhoneVerificationService: Error - $e');
      return PhoneVerificationResponse.error('An unexpected error occurred');
    }
  }

  /// Verify OTP code.
  Future<OtpVerificationResult> verifyOtp({
    required String verificationId,
    required String code,
    required String uid,
  }) async {
    try {
      debugPrint('PhoneVerificationService: Verifying OTP');

      final request = OtpVerificationRequest(
        verificationId: verificationId,
        code: code,
        uid: uid,
      );

      final response = await _dio.post(
        '/api/users/verifyOtp',
        data: request.toJson(),
      );

      final result = OtpVerificationResult.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (result.isSuccess) {
        debugPrint('PhoneVerificationService: OTP verified successfully');
        // Update cache optimistically
        markAsVerified(uid);
      } else {
        debugPrint('PhoneVerificationService: Failed - ${result.message}');
      }

      return result;
    } on DioException catch (e) {
      debugPrint('PhoneVerificationService: DioException - ${e.message}');

      if (e.error is ApiError) {
        final apiError = e.error as ApiError;
        return OtpVerificationResult.error(apiError.message);
      }

      if (e.response?.data != null) {
        try {
          return OtpVerificationResult.fromJson(
            e.response!.data as Map<String, dynamic>,
          );
        } catch (_) {}
      }

      return OtpVerificationResult.error(
        e.message ?? 'Failed to verify OTP',
      );
    } catch (e) {
      debugPrint('PhoneVerificationService: Error - $e');
      return OtpVerificationResult.error('An unexpected error occurred');
    }
  }
}
