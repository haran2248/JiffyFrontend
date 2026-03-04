import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:share_plus/share_plus.dart';
import 'data/coupon_model.dart';
import 'data/rewards_notifier.dart';

/// Rewards & Referrals screen — shows user's coupons and referral code.
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(rewardsProvider);
    final notifier = ref.read(rewardsProvider.notifier);

    // Show snackbars for redeem feedback
    ref.listen(rewardsProvider, (prev, next) {
      if (next.redeemSuccess != null &&
          next.redeemSuccess != prev?.redeemSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.redeemSuccess!),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        notifier.clearRedeemMessages();
      }
      if (next.redeemError != null && next.redeemError != prev?.redeemError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.redeemError!),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        notifier.clearRedeemMessages();
      }
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: colorScheme.onSurface),
            onPressed: () => context.popRoute(),
          ),
          title: Text(
            'Rewards & Referrals',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor:
                colorScheme.onSurface.withValues(alpha: 0.5),
            indicatorColor: colorScheme.primary,
            tabs: [
              Tab(
                text: state.availableCoupons.isEmpty
                    ? 'Available'
                    : 'Available (${state.availableCoupons.length})',
              ),
              const Tab(text: 'Expired / Used'),
            ],
          ),
        ),
        body: state.isLoading
            ? Center(
                child: CircularProgressIndicator(color: colorScheme.primary))
            : state.error != null
                ? _ErrorView(
                    message: state.error!,
                    onRetry: notifier.load,
                  )
                : TabBarView(
                    children: [
                      _CouponsTab(
                        coupons: state.availableCoupons,
                        referralCode: state.referralCode,
                        isRedeeming: state.isRedeeming,
                        onRedeem: notifier.redeem,
                        emptyMessage: 'No coupons available right now',
                      ),
                      _CouponsTab(
                        coupons: state.expiredOrUsedCoupons,
                        referralCode: null, // Don't show referral on expired tab
                        isRedeeming: false,
                        onRedeem: null,
                        emptyMessage: 'No expired or used coupons',
                      ),
                    ],
                  ),
      ),
    );
  }
}

// ── Tab with coupon list + referral card ──────────────────────────────────────

class _CouponsTab extends StatelessWidget {
  final List<Coupon> coupons;
  final String? referralCode;
  final bool isRedeeming;
  final void Function(Coupon)? onRedeem;
  final String emptyMessage;

  const _CouponsTab({
    required this.coupons,
    required this.referralCode,
    required this.isRedeeming,
    required this.onRedeem,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: () async {
        // Trigger reload via provider
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (coupons.isNotEmpty) ...[
            Text(
              coupons.first.isAvailable
                  ? 'Available Coupons'
                  : 'Expired & Used',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...coupons.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CouponCard(
                    coupon: c,
                    isRedeeming: isRedeeming,
                    onRedeem: onRedeem != null ? () => onRedeem!(c) : null,
                  ),
                )),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.redeem_rounded,
                        size: 56,
                        color: colorScheme.onSurface.withValues(alpha: 0.25)),
                    const SizedBox(height: 12),
                    Text(
                      emptyMessage,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (referralCode != null) ...[
            const SizedBox(height: 8),
            _ReferralCard(referralCode: referralCode!),
          ],
        ],
      ),
    );
  }
}

// ── Coupon card ───────────────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  final Coupon coupon;
  final bool isRedeeming;
  final VoidCallback? onRedeem;

  const _CouponCard({
    required this.coupon,
    required this.isRedeeming,
    this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isUsed = coupon.status == CouponStatus.used;
    final isExpired = coupon.status == CouponStatus.expired;
    final isLocked = coupon.status == CouponStatus.locked;
    final dimmed = isUsed || isExpired || isLocked;

    return Opacity(
      opacity: dimmed ? 0.55 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dimmed
                ? colorScheme.outline.withValues(alpha: 0.1)
                : colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Discount badge
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: dimmed
                    ? null
                    : LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: dimmed
                    ? colorScheme.outline.withValues(alpha: 0.15)
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  coupon.discountLabel,
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: dimmed
                        ? colorScheme.onSurface.withValues(alpha: 0.5)
                        : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.category.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: dimmed
                          ? colorScheme.onSurface.withValues(alpha: 0.4)
                          : colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    coupon.title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coupon.description,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (coupon.validUntil != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Valid until ${_formatDate(coupon.validUntil!)}',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (isUsed)
                    _StatusChip(label: 'Redeemed', color: Colors.grey)
                  else if (isExpired)
                    _StatusChip(label: 'Expired', color: colorScheme.error)
                  else if (isLocked)
                    _StatusChip(
                        label: 'Locked — share your referral code to unlock',
                        color: colorScheme.outline)
                  else
                    FilledButton(
                      onPressed: isRedeeming ? null : onRedeem,
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: isRedeeming
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Redeem Now'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
    );
  }
}

// ── Referral card ─────────────────────────────────────────────────────────────

class _ReferralCard extends StatelessWidget {
  final String referralCode;
  const _ReferralCard({required this.referralCode});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.15),
            colorScheme.secondary.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars_rounded, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Invite friends, earn rewards',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Share your code — when a friend signs up, you both unlock exclusive date discounts.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'YOUR REFERRAL CODE',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                referralCode,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: referralCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Referral code copied!'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(Icons.copy_rounded,
                    color: colorScheme.primary, size: 20),
                tooltip: 'Copy code',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Share.share(
                  'Join me on Jiffy! Use my referral code $referralCode when you sign up and we both get exclusive date discounts. 🎉',
                  subject: 'Join Jiffy with my referral code',
                );
              },
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Share Code'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
