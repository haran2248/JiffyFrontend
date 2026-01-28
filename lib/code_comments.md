This is a comment left during a code review.

**Path:** lib/core/services/phone_verification_service.dart
**Line:** 79:79
**Comment:**
	*Security: The new error logging prints the full HTTP response body, which can include sensitive user data (phone numbers, OTP codes, tokens, etc.) and may end up in logs or external logging systems, creating a potential information disclosure vulnerability; it's safer to log only high-level metadata like the status code and perhaps a minimal summary, not the entire `data` payload.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

----------------------

This is a comment left during a code review.

**Path:** lib/presentation/screens/login/login_screen.dart
**Line:** 58:65
**Comment:**
	*Logic Error: All exceptions from backend verification are currently treated as a stale session and cause an immediate sign-out, which means transient network or server errors will log the user out and prevent navigation, conflicting with the more tolerant behavior in the auth viewmodel and leading to unnecessary logouts on temporary backend issues.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

----------------------

In `@lib/core/services/phone_verification_service.dart` around lines 78 - 80, The
current catch block in PhoneVerificationService logs the full HTTP response
payload (e.response?.data), which can contain PII; update the debugPrint in the
error handling to omit or redact the response body and only log safe metadata
such as e.response?.statusCode (or a fixed placeholder like "<redacted>" for the
body) so no phone numbers or UIDs are written to device logs; locate the logging
in the PhoneVerificationService error/catch handler where e.response is
referenced and replace the data interpolation with status-only or redacted text.

} catch (e) {
  debugPrint('LoginScreen: Backend verification failed: $e');
  final apiError = (e is DioException) ? e.error as ApiError? : null;
  if (apiError?.isAuthError == true) {
    // Only sign out on auth errors
    debugPrint('LoginScreen: Signing out due to invalid session');
    await authRepo.signOut();
    _hasNavigated = false;
    return false;
  } else {
    // For transient failures, stay on login to allow retry
    debugPrint('LoginScreen: Transient error, staying on login');
    return false;
  }
}