import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jiffy/presentation/screens/rewards/data/coupon_repository.dart';

class ShareService {
  static const String _cachedReferralKey = 'cached_user_referral_code';
  static const String appShareLink = 'https://onelink.to/gdbxa5';

  /// In-memory cache for fast, synchronous retrieval during the session.
  static String? _inMemoryCode;

  /// Retrieves the referral code for the currently logged-in user.
  /// Checks memory, then local storage, then queries the backend API.
  static Future<String?> getReferralCode(WidgetRef ref) async {
    if (_inMemoryCode != null && _inMemoryCode!.isNotEmpty) {
      return _inMemoryCode;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('${_cachedReferralKey}_$uid');
      if (cached != null && cached.isNotEmpty) {
        _inMemoryCode = cached;
        return cached;
      }

      final repo = ref.read(couponRepositoryProvider);
      final code = await repo.getOrCreateReferralCode(uid);
      if (code.isNotEmpty) {
        _inMemoryCode = code;
        await prefs.setString('${_cachedReferralKey}_$uid', code);
        return code;
      }
    } catch (e) {
      debugPrint('[ShareService] Error fetching referral code: $e');
    }
    return null;
  }

  /// Builds the share message with the referral code if available.
  static String buildShareMessage(String? referralCode) {
    if (referralCode != null && referralCode.trim().isNotEmpty) {
      return 'Let AI help you find your date, download now. Open to all bangalore colleges inclusive Christ, SJCC, Kristu \nUse referralCode "$referralCode" to get access.\n$appShareLink';
    }
    return 'Let AI help you find your date, download now. Open to all bangalore colleges inclusive Christ, SJCC, Kristu \n$appShareLink';
  }

  /// Triggers the native platform share dialog.
  static Future<void> shareApp(
    BuildContext context,
    WidgetRef ref, {
    Rect? sharePositionOrigin,
  }) async {
    final code = await getReferralCode(ref);
    final message = buildShareMessage(code);

    await Share.share(
      message,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
