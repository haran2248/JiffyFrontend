import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:jiffy/core/services/phone_verification_service.dart';
import '../models/phone_verification_models.dart';

part 'phone_verification_viewmodel.g.dart';

/// ViewModel for phone verification flow.
///
/// Manages:
/// - Phone number input state
/// - OTP code state
/// - API calls for sending/verifying OTP
/// - Resend countdown timer
/// - Loading and error states
@riverpod
class PhoneVerificationViewModel extends _$PhoneVerificationViewModel {
  Timer? _resendTimer;

  @override
  PhoneVerificationState build() {
    // Cleanup timer on dispose
    ref.onDispose(() {
      _resendTimer?.cancel();
    });

    return const PhoneVerificationState();
  }

  /// Get the current user's UID from Firebase Auth.
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Update the phone number.
  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(
      phoneNumber: phoneNumber,
      errorMessage: null,
    );
  }

  /// Update the OTP code.
  void updateOtpCode(String code) {
    state = state.copyWith(
      otpCode: code,
      errorMessage: null,
    );
  }

  /// Send verification code to the phone number.
  ///
  /// Returns true on success, false on failure.
  Future<bool> sendVerificationCode() async {
    final uid = _uid;
    if (uid == null) {
      state = state.copyWith(errorMessage: 'User not authenticated');
      return false;
    }

    if (!state.canSendOtp) {
      state = state.copyWith(errorMessage: 'Please enter a valid phone number');
      return false;
    }

    state = state.copyWith(
      isSendingOtp: true,
      errorMessage: null,
    );

    try {
      final service = ref.read(phoneVerificationServiceProvider);
      final response = await service.sendVerificationCode(
        phoneNumber: state.phoneNumber,
        uid: uid,
      );

      if (response.isSuccess && response.data?.verificationId != null) {
        state = state.copyWith(
          isSendingOtp: false,
          isOtpSent: true,
          verificationId: response.data!.verificationId,
        );
        _startResendTimer();
        return true;
      } else {
        state = state.copyWith(
          isSendingOtp: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (e) {
      debugPrint('PhoneVerificationViewModel: Error sending OTP - $e');
      state = state.copyWith(
        isSendingOtp: false,
        errorMessage: 'Failed to send verification code',
      );
      return false;
    }
  }

  /// Verify the OTP code.
  ///
  /// Returns true on success, false on failure.
  Future<bool> verifyOtp() async {
    final uid = _uid;
    if (uid == null) {
      state = state.copyWith(errorMessage: 'User not authenticated');
      return false;
    }

    if (state.verificationId == null) {
      state = state.copyWith(errorMessage: 'Please request a new code');
      return false;
    }

    if (!state.canVerifyOtp) {
      state = state.copyWith(errorMessage: 'Please enter a 4-digit code');
      return false;
    }

    state = state.copyWith(
      isVerifyingOtp: true,
      errorMessage: null,
    );

    try {
      final service = ref.read(phoneVerificationServiceProvider);
      final result = await service.verifyOtp(
        verificationId: state.verificationId!,
        code: state.otpCode,
        uid: uid,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          isVerifyingOtp: false,
          isVerified: true,
        );
        _resendTimer?.cancel();
        return true;
      } else {
        state = state.copyWith(
          isVerifyingOtp: false,
          errorMessage: result.message,
        );
        return false;
      }
    } catch (e) {
      debugPrint('PhoneVerificationViewModel: Error verifying OTP - $e');
      state = state.copyWith(
        isVerifyingOtp: false,
        errorMessage: 'Failed to verify code',
      );
      return false;
    }
  }

  /// Resend the verification code.
  Future<bool> resendCode() async {
    if (!state.canResend) return false;
    return sendVerificationCode();
  }

  /// Start the resend countdown timer.
  void _startResendTimer() {
    _resendTimer?.cancel();
    state = state.copyWith(resendCountdown: 30);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCountdown > 0) {
        state = state.copyWith(resendCountdown: state.resendCountdown - 1);
      } else {
        timer.cancel();
      }
    });
  }

  /// Clear error message.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset the state for a new verification attempt.
  void reset() {
    _resendTimer?.cancel();
    state = const PhoneVerificationState();
  }
}
