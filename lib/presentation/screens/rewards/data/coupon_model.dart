/// Coupon data models for the Rewards & Referrals feature.

enum DiscountType { percent, fixed }

enum CouponStatus { active, used, expired, locked }

class Coupon {
  final String id;
  final String title;
  final String description;
  final String category;
  final String redemptionCode;
  final double discountValue;
  final DiscountType discountType;
  final CouponStatus status;
  final String? genderTarget;
  final bool requiresReferral;
  final String? referralCode;
  final DateTime? validUntil;
  final DateTime? redeemedAt;

  const Coupon({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.redemptionCode,
    required this.discountValue,
    required this.discountType,
    required this.status,
    this.genderTarget,
    this.requiresReferral = false,
    this.referralCode,
    this.validUntil,
    this.redeemedAt,
  });

  bool get isAvailable => status == CouponStatus.active;
  bool get isLocked => status == CouponStatus.locked;
  bool get isExpiredOrUsed =>
      status == CouponStatus.expired || status == CouponStatus.used;

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      redemptionCode: json['redemptionCode'] as String? ?? '',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
      discountType: json['discountType'] == 'PERCENT'
          ? DiscountType.percent
          : DiscountType.fixed,
      status: _parseStatus(json['status'] as String?),
      genderTarget: json['genderTarget'] as String?,
      requiresReferral: json['requiresReferral'] as bool? ?? false,
      referralCode: json['referralCode'] as String?,
      validUntil: json['validUntil'] != null
          ? DateTime.tryParse(json['validUntil'] as String)
          : null,
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.tryParse(json['redeemedAt'] as String)
          : null,
    );
  }

  static CouponStatus _parseStatus(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'USED':
        return CouponStatus.used;
      case 'EXPIRED':
        return CouponStatus.expired;
      case 'LOCKED':
        return CouponStatus.locked;
      default:
        return CouponStatus.active;
    }
  }

  String get discountLabel {
    if (discountType == DiscountType.percent) {
      return '${discountValue.toInt()}% OFF';
    }
    return '₹${discountValue.toInt()} OFF';
  }
}
