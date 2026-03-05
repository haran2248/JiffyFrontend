import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import 'coupon_model.dart';

/// Repository for all Coupon API operations.
class CouponRepository {
  final Dio _dio;

  CouponRepository(this._dio);

  /// GET /api/coupons?userId=
  /// Returns all coupons for the given user.
  Future<List<Coupon>> fetchCoupons(String userId) async {
    try {
      final response = await _dio.get(
        '/api/coupons',
        queryParameters: {'userId': userId},
      );
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('CouponRepository.fetchCoupons error: $e');
      rethrow;
    }
  }

  /// GET /api/coupons/<couponId>
  Future<Coupon> fetchCoupon(String couponId) async {
    final response = await _dio.get('/api/coupons/$couponId');
    return Coupon.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /api/coupons/redeem { couponId, userId }
  /// Returns 409 if already redeemed/expired.
  Future<void> redeemCoupon({
    required String couponId,
    required String userId,
  }) async {
    try {
      await _dio.post(
        '/api/coupons/redeem',
        data: {'couponId': couponId, 'userId': userId},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const CouponAlreadyRedeemedException();
      }
      rethrow;
    }
  }

  /// POST /api/coupons/referral-code?userId=
  /// Idempotent — returns the existing code if already generated.
  /// Returns the referral code string.
  Future<String> getOrCreateReferralCode(String userId) async {
    final response = await _dio.post(
      '/api/coupons/referral-code',
      queryParameters: {'userId': userId},
      options: Options(responseType: ResponseType.plain),
    );
    // Server returns the code as plain text
    final data = response.data;
    if (data is String) return data.trim();
    if (data is Map) {
      return data['referralCode']?.toString() ?? data['code']?.toString() ?? '';
    }
    return '';
  }

  /// GET /api/coupons/redemptions?userId=
  Future<List<Coupon>> fetchRedemptionHistory(String userId) async {
    final response = await _dio.get(
      '/api/coupons/redemptions',
      queryParameters: {'userId': userId},
    );
    final list = response.data as List<dynamic>? ?? [];
    return list.map((e) => Coupon.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /api/coupons/activate-referral?referralCode=&newUserId=
  /// Called during signup when a new user registers with a referral code.
  Future<void> activateReferral({
    required String referralCode,
    required String newUserId,
  }) async {
    await _dio.post(
      '/api/coupons/activate-referral',
      queryParameters: {
        'referralCode': referralCode,
        'newUserId': newUserId,
      },
    );
  }
}

class CouponAlreadyRedeemedException implements Exception {
  const CouponAlreadyRedeemedException();
  @override
  String toString() => 'This coupon has already been redeemed or has expired.';
}

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  return CouponRepository(ref.read(dioProvider));
});
