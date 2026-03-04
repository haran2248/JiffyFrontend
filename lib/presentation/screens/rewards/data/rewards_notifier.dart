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
  final bool isRedeeming;
  final String? redeemError;
  final String? redeemSuccess;

  const RewardsState({
    this.isLoading = false,
    this.error,
    this.coupons = const [],
    this.referralCode,
    this.isRedeeming = false,
    this.redeemError,
    this.redeemSuccess,
  });

  List<Coupon> get availableCoupons =>
      coupons.where((c) => c.isAvailable).toList();

  List<Coupon> get expiredOrUsedCoupons =>
      coupons.where((c) => c.isExpiredOrUsed).toList();

  RewardsState copyWith({
    bool? isLoading,
    String? Function()? error,
    List<Coupon>? coupons,
    String? Function()? referralCode,
    bool? isRedeeming,
    String? Function()? redeemError,
    String? Function()? redeemSuccess,
  }) {
    return RewardsState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      coupons: coupons ?? this.coupons,
      referralCode: referralCode != null ? referralCode() : this.referralCode,
      isRedeeming: isRedeeming ?? this.isRedeeming,
      redeemError: redeemError != null ? redeemError() : this.redeemError,
      redeemSuccess:
          redeemSuccess != null ? redeemSuccess() : this.redeemSuccess,
    );
  }
}

/// Notifier for the Rewards screen.
class RewardsNotifier extends StateNotifier<RewardsState> {
  final CouponRepository _repo;
  final AuthRepository _auth;

  RewardsNotifier(this._repo, this._auth) : super(const RewardsState()) {
    load();
  }

  String? get _uid => _auth.currentUser?.uid;

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) return;

    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final results = await Future.wait([
        _repo.fetchCoupons(uid),
        _repo.getOrCreateReferralCode(uid),
      ]);

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        coupons: results[0] as List<Coupon>,
        referralCode: () => results[1] as String,
      );
    } catch (e) {
      debugPrint('RewardsNotifier.load error: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: () => 'Could not load rewards. Please try again.',
      );
    }
  }

  Future<void> redeem(Coupon coupon) async {
    final uid = _uid;
    if (uid == null) return;

    state = state.copyWith(
      isRedeeming: true,
      redeemError: () => null,
      redeemSuccess: () => null,
    );

    try {
      await _repo.redeemCoupon(couponId: coupon.id, userId: uid);
      if (!mounted) return;
      // Reload coupons to reflect updated status
      final updated = await _repo.fetchCoupons(uid);
      if (!mounted) return;
      state = state.copyWith(
        isRedeeming: false,
        coupons: updated,
        redeemSuccess: () => '"${coupon.title}" redeemed! '
            'Use code ${coupon.redemptionCode} at checkout.',
      );
    } on CouponAlreadyRedeemedException {
      if (!mounted) return;
      state = state.copyWith(
        isRedeeming: false,
        redeemError: () =>
            'This coupon has already been redeemed or has expired.',
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isRedeeming: false,
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
    StateNotifierProvider<RewardsNotifier, RewardsState>((ref) {
  return RewardsNotifier(
    ref.read(couponRepositoryProvider),
    ref.read(authRepositoryProvider),
  );
});
