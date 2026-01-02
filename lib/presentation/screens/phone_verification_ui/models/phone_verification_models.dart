// Models for phone verification API integration.
//
// These models match the SwishBackend API structure for:
// - POST /api/users/updatePhoneNumber
// - POST /api/users/verifyOtp

/// Request to send verification code to a phone number.
class PhoneVerificationRequest {
  final String uid;
  final String phoneNumber;

  const PhoneVerificationRequest({
    required this.uid,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'phoneNumber': phoneNumber,
      };
}

/// Response from sending verification code.
class PhoneVerificationResponse {
  final int responseCode;
  final String message;
  final VerificationData? data;

  const PhoneVerificationResponse({
    required this.responseCode,
    required this.message,
    this.data,
  });

  bool get isSuccess => responseCode == 200;

  factory PhoneVerificationResponse.fromJson(Map<String, dynamic> json) {
    return PhoneVerificationResponse(
      responseCode: json['responseCode'] as int? ?? 400,
      message: json['message'] as String? ?? 'Unknown error',
      data: json['data'] != null
          ? VerificationData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  factory PhoneVerificationResponse.error(String message) {
    return PhoneVerificationResponse(
      responseCode: 400,
      message: message,
      data: null,
    );
  }
}

/// Verification data returned when OTP is sent.
class VerificationData {
  final String? verificationId;
  final String? mobileNumber;
  final String? responseCode;
  final String? timeout;
  final String? transactionId;
  final String? flowType;

  const VerificationData({
    this.verificationId,
    this.mobileNumber,
    this.responseCode,
    this.timeout,
    this.transactionId,
    this.flowType,
  });

  factory VerificationData.fromJson(Map<String, dynamic> json) {
    return VerificationData(
      verificationId: json['verificationId'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      responseCode: json['responseCode'] as String?,
      timeout: json['timeout'] as String?,
      transactionId: json['transactionId'] as String?,
      flowType: json['flowType'] as String?,
    );
  }
}

/// Request to verify OTP code.
class OtpVerificationRequest {
  final String verificationId;
  final String code;
  final String uid;

  const OtpVerificationRequest({
    required this.verificationId,
    required this.code,
    required this.uid,
  });

  Map<String, dynamic> toJson() => {
        'verificationId': verificationId,
        'code': code,
        'uid': uid,
      };
}

/// Result from OTP verification.
class OtpVerificationResult {
  final int responseCode;
  final String message;
  final OtpVerificationData? data;

  const OtpVerificationResult({
    required this.responseCode,
    required this.message,
    this.data,
  });

  bool get isSuccess => responseCode == 200;

  factory OtpVerificationResult.fromJson(Map<String, dynamic> json) {
    return OtpVerificationResult(
      responseCode: json['responseCode'] as int? ?? 400,
      message: json['message'] as String? ?? 'Unknown error',
      data: json['data'] != null
          ? OtpVerificationData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  factory OtpVerificationResult.error(String message) {
    return OtpVerificationResult(
      responseCode: 400,
      message: message,
      data: null,
    );
  }
}

/// Data returned from OTP verification.
class OtpVerificationData {
  final String? verificationId;
  final String? mobileNumber;
  final String? responseCode;
  final String? errorMessage;
  final String? verificationStatus;
  final String? authToken;
  final String? transactionId;

  const OtpVerificationData({
    this.verificationId,
    this.mobileNumber,
    this.responseCode,
    this.errorMessage,
    this.verificationStatus,
    this.authToken,
    this.transactionId,
  });

  bool get isVerified => verificationStatus == 'VERIFICATION_COMPLETED';

  factory OtpVerificationData.fromJson(Map<String, dynamic> json) {
    return OtpVerificationData(
      verificationId: json['verificationId'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      responseCode: json['responseCode'] as String?,
      errorMessage: json['errorMessage'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
      authToken: json['authToken'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }
}

/// UI state for phone verification flow.
class PhoneVerificationState {
  final String phoneNumber;
  final String otpCode;
  final String? verificationId;
  final bool isLoading;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final String? errorMessage;
  final int resendCountdown;
  final bool isOtpSent;
  final bool isVerified;

  const PhoneVerificationState({
    this.phoneNumber = '',
    this.otpCode = '',
    this.verificationId,
    this.isLoading = false,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.errorMessage,
    this.resendCountdown = 0,
    this.isOtpSent = false,
    this.isVerified = false,
  });

  bool get canSendOtp => phoneNumber.length >= 10 && !isSendingOtp;
  bool get canVerifyOtp => otpCode.length == 4 && !isVerifyingOtp;
  bool get canResend => resendCountdown == 0 && !isSendingOtp;

  PhoneVerificationState copyWith({
    String? phoneNumber,
    String? otpCode,
    String? verificationId,
    bool? isLoading,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    String? errorMessage,
    int? resendCountdown,
    bool? isOtpSent,
    bool? isVerified,
  }) {
    return PhoneVerificationState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      verificationId: verificationId ?? this.verificationId,
      isLoading: isLoading ?? this.isLoading,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      errorMessage: errorMessage,
      resendCountdown: resendCountdown ?? this.resendCountdown,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
