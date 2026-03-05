import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/auth/auth_repository.dart';
import 'coupon_model.dart';
import 'coupon_repository.dart';

/// State for the rewards screen.
class RewardsState {
  final bool isLoading;
  final String? error;
  final List<Coupon> coupons;
  final String? referralCode;
  final String? redeemingCouponId;
  final String? redeemError;
  final String? redeemSuccess;

  const RewardsState({
    this.isLoading = false,
    this.error,
    this.coupons = const [],
    this.referralCode,
    this.redeemingCouponId,
    this.redeemError,
    this.redeemSuccess,
  });

  List<Coupon> get availableCoupons =>
      coupons.where((c) => c.isAvailable || c.isLocked).toList();

  List<Coupon> get expiredOrUsedCoupons =>
      coupons.where((c) => c.isExpiredOrUsed).toList();

  bool isRedeemingCoupon(String couponId) => redeemingCouponId == couponId;

  RewardsState copyWith({
    bool? isLoading,
    String? Function()? error,
    List<Coupon>? coupons,
    String? Function()? referralCode,
    String? Function()? redeemingCouponId,
    String? Function()? redeemError,
    String? Function()? redeemSuccess,
  }) {
    return RewardsState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      coupons: coupons ?? this.coupons,
      referralCode: referralCode != null ? referralCode() : this.referralCode,
      redeemingCouponId: redeemingCouponId != null
          ? redeemingCouponId()
          : this.redeemingCouponId,
      redeemError: redeemError != null ? redeemError() : this.redeemError,
      redeemSuccess:
          redeemSuccess != null ? redeemSuccess() : this.redeemSuccess,
    );
  }
}

/// Notifier for the Rewards screen.
class RewardsNotifier extends Notifier<RewardsState> {
  late final CouponRepository _repo;
  late final AuthRepository _auth;

  @override
  RewardsState build() {
    _repo = ref.read(couponRepositoryProvider);
    _auth = ref.read(authRepositoryProvider);
    // Trigger initial load after build
    Future.microtask(load);
    return const RewardsState();
  }

  String? get _uid => _auth.currentUser?.uid;

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) return;

    state = state.copyWith(isLoading: true, error: () => null);

    try {
      // Fetch coupons — this is the critical call; failure shows an error.
      final coupons = await _repo.fetchCoupons(uid);

      // Fetch referral code independently — failure is non-fatal.
      String? referralCode;
      try {
        referralCode = await _repo.getOrCreateReferralCode(uid);
      } catch (e) {
        debugPrint('RewardsNotifier.load referral code error (non-fatal): $e');
      }

      state = state.copyWith(
        isLoading: false,
        coupons: coupons,
        referralCode: () => referralCode,
      );
    } catch (e) {
      debugPrint('RewardsNotifier.load error: $e');
      state = state.copyWith(
        isLoading: false,
        error: () => 'Could not load rewards. Please try again.',
      );
    }
  }

  Future<void> redeem(Coupon coupon) async {
    final uid = _uid;
    if (uid == null) return;

    // Optimistically flip this coupon to 'used' immediately so the UI
    // responds without waiting for the network round-trip.
    final optimisticCoupons = state.coupons.map((c) {
      if (c.id == coupon.id) {
        return Coupon(
          id: c.id,
          title: c.title,
          description: c.description,
          category: c.category,
          redemptionCode: c.redemptionCode,
          discountValue: c.discountValue,
          discountType: c.discountType,
          status: CouponStatus.used,
          genderTarget: c.genderTarget,
          requiresReferral: c.requiresReferral,
          referralCode: c.referralCode,
          validUntil: c.validUntil,
          redeemedAt: DateTime.now(),
        );
      }
      return c;
    }).toList();

    state = state.copyWith(
      redeemingCouponId: () => coupon.id,
      coupons: optimisticCoupons,
      redeemError: () => null,
      redeemSuccess: () => null,
    );

    try {
      await _repo.redeemCoupon(couponId: coupon.id, userId: uid);
      // Confirm with the real server state
      final updated = await _repo.fetchCoupons(uid);
      state = state.copyWith(
        redeemingCouponId: () => null,
        coupons: updated,
        redeemSuccess: () => '"${coupon.title}" redeemed! '
            'Use code ${coupon.redemptionCode} at checkout.',
      );
    } on CouponAlreadyRedeemedException {
      // Coupon was already redeemed server-side — keep it as used
      state = state.copyWith(
        redeemingCouponId: () => null,
        redeemError: () =>
            'This coupon has already been redeemed or has expired.',
      );
    } catch (e) {
      // Roll back the optimistic update on failure
      state = state.copyWith(
        redeemingCouponId: () => null,
        coupons: state.coupons.map((c) {
          if (c.id == coupon.id) return coupon; // restore original
          return c;
        }).toList(),
        redeemError: () => 'Failed to redeem coupon. Please try again.',
      );
    }
  }

  void clearRedeemMessages() {
    state = state.copyWith(
      redeemError: () => null,
      redeemSuccess: () => null,
    );
  }
}

final rewardsProvider =
    NotifierProvider<RewardsNotifier, RewardsState>(RewardsNotifier.new);
