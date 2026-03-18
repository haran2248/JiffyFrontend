/// API endpoint definitions for the coupon domain.
class CouponApiEndpoints {
  // Private constructor to prevent instantiation
  CouponApiEndpoints._();

  /// Base path for coupon-related endpoints
  static const String basePath = '/api/coupons';

  /// Activate referral coupons for a new user
  /// POST /api/coupons/activate-referral?referralCode={code}&newUserId={uid}
  static const String activateReferral = '$basePath/activate-referral';
}
