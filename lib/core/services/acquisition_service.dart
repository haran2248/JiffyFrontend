import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing user acquisition tracking, Meta SDK initialization,
/// Android install referrer parsing, and funnel milestones.
///
/// Hard constraints:
/// - Analytics never blocks startup, login, or onboarding.
/// - Never crashes the app; all calls are safely wrapped.
/// - Zero profile/user data is sent to Meta (only automatic installs & app opens).
class AcquisitionService {
  static const String _channelName = 'com.jiffydating.app/install_referrer';
  static const MethodChannel _installReferrerChannel = MethodChannel(_channelName);

  // Storage keys
  static const String keyInstallReferrerChecked = 'install_referrer_checked';
  static const String keyPendingSource = 'pending_acquisition_source';
  static const String keyPendingSourceTimestamp = 'pending_acquisition_source_timestamp';
  static const String keyPlayReferrerSent = 'play_referrer_source_sent';
  static const String keyInviteCodeSet = 'invite_code_source_set';
  static const String keyFirstMessageReported = 'firstMessageReported';

  // Validation pattern for source codes
  static final RegExp sourceRegex = RegExp(r'^[A-Z0-9_]{3,40}$');

  final FacebookAppEvents _facebookAppEvents;
  final Dio? _dio;
  final FirebaseAuth _auth;

  AcquisitionService({
    FacebookAppEvents? facebookAppEvents,
    Dio? dio,
    FirebaseAuth? auth,
  })  : _facebookAppEvents = facebookAppEvents ?? FacebookAppEvents(),
        _dio = dio,
        _auth = auth ?? FirebaseAuth.instance;

  /// Initializes Meta SDK as early as possible on startup.
  /// Non-blocking, fails silently on any error.
  Future<void> initialize() async {
    try {
      // Automatic install and app open logging only.
      // Send NO profile data to Meta.
      await _facebookAppEvents.setAutoLogAppEventsEnabled(true);
      await _facebookAppEvents.setAdvertiserIdCollectionEnabled(true);
      debugPrint('[AcquisitionService] Meta SDK initialized successfully.');
    } catch (e) {
      debugPrint('[AcquisitionService] Meta SDK initialization skipped/failed: $e');
    }

    // Check Android install referrer on first launch in the background
    if (!kIsWeb && Platform.isAndroid) {
      unawaited(checkAndroidInstallReferrerOnFirstLaunch());
    }
  }

  /// On FIRST launch only, reads the Google Play Install Referrer.
  /// 5-second timeout; on error stores nothing and moves on.
  Future<void> checkAndroidInstallReferrerOnFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyChecked = prefs.getBool(keyInstallReferrerChecked) ?? false;
      if (alreadyChecked) {
        return;
      }

      // Mark as checked immediately so subsequent launches never repeat this
      await prefs.setBool(keyInstallReferrerChecked, true);

      debugPrint('[AcquisitionService] Querying Play Install Referrer on first launch...');
      final String? rawReferrer = await _installReferrerChannel
          .invokeMethod<String>('getInstallReferrer')
          .timeout(const Duration(seconds: 5));

      if (rawReferrer == null || rawReferrer.trim().isEmpty) {
        debugPrint('[AcquisitionService] Empty install referrer.');
        return;
      }

      final mappedSource = parseReferrerToSource(rawReferrer);
      if (mappedSource != null) {
        debugPrint('[AcquisitionService] Mapped install referrer source: $mappedSource');
        await prefs.setString(keyPendingSource, mappedSource);
        await prefs.setInt(keyPendingSourceTimestamp, DateTime.now().millisecondsSinceEpoch);
      } else {
        debugPrint('[AcquisitionService] Referrer parsed to no actionable source.');
      }
    } catch (e) {
      debugPrint('[AcquisitionService] Install referrer check ignored/timed out: $e');
      // Store nothing and silently move on
    }
  }

  /// Parses a raw Google Play referrer query string into a normalized source code:
  /// - utm_source contains "facebook" or "instagram" -> "META_ANDROID"
  /// - utm_source matches ^[A-Za-z0-9_]{3,40}$ and isn't google-play/organic/(not set) -> uppercased
  /// - "google-play" / "(not set)" / organic / empty / error -> null
  static String? parseReferrerToSource(String rawReferrer) {
    try {
      String decoded = rawReferrer.trim();
      // Handle potential double encoding
      if (decoded.contains('%26') || decoded.contains('%3D') || decoded.contains('%3d')) {
        decoded = Uri.decodeComponent(decoded);
      }

      final queryParams = Uri.splitQueryString(decoded);
      final utmSource = queryParams['utm_source']?.trim();

      if (utmSource == null || utmSource.isEmpty) {
        return null;
      }

      final lower = utmSource.toLowerCase();

      // Check for organic / empty equivalents
      if (lower == 'google-play' || lower == '(not set)' || lower == 'organic') {
        return null;
      }

      // Meta ad installs
      if (lower.contains('facebook') || lower.contains('instagram')) {
        return 'META_ANDROID';
      }

      // Custom campaign/link sources matching regex
      final upper = utmSource.toUpperCase();
      if (sourceRegex.hasMatch(upper)) {
        return upper;
      }

      return null;
    } catch (e) {
      debugPrint('[AcquisitionService] Error parsing referrer string: $e');
      return null;
    }
  }

  /// Sends pending play_referrer source after successful login or on launch.
  /// Retries for up to 7 days, then drops. Never throws or blocks navigation.
  Future<void> sendPendingSourceAfterLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingSource = prefs.getString(keyPendingSource);
      if (pendingSource == null || pendingSource.isEmpty) {
        return;
      }

      // Check 7-day expiration
      final timestamp = prefs.getInt(keyPendingSourceTimestamp);
      if (timestamp != null) {
        final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
        if (age.inDays > 7) {
          debugPrint('[AcquisitionService] Pending source expired (>7 days). Dropping.');
          await prefs.remove(keyPendingSource);
          await prefs.remove(keyPendingSourceTimestamp);
          return;
        }
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return;
      }

      final token = await currentUser.getIdToken();
      final dio = _dio;
      if (token == null || dio == null) {
        return;
      }

      debugPrint('[AcquisitionService] Sending pending acquisition source: $pendingSource');
      final response = await dio.put(
        '/me/source',
        data: {
          'source': pendingSource,
          'method': 'play_referrer',
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[AcquisitionService] Acquisition source successfully sent.');
        await prefs.remove(keyPendingSource);
        await prefs.remove(keyPendingSourceTimestamp);
        await prefs.setBool(keyPlayReferrerSent, true);
      }
    } catch (e) {
      debugPrint('[AcquisitionService] Failed to send acquisition source (will retry on next app start): $e');
    }
  }

  /// Checks if an invite code was already submitted for this user.
  Future<bool> hasInviteCodeSet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(keyInviteCodeSet) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Validates and submits an invite code:
  /// - Uppercased, trimmed.
  /// - Validated against ^[A-Z0-9_]{3,40}$ client-side.
  /// - PUT /me/source { source, method: "invite_code" }
  Future<({bool success, String message})> submitInviteCode(String rawCode) async {
    final code = rawCode.trim().toUpperCase();

    if (!sourceRegex.hasMatch(code)) {
      return (success: false, message: "That code doesn't look right");
    }

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return (success: false, message: "That code doesn't look right");
      }

      final token = await currentUser.getIdToken();
      final dio = _dio;
      if (token == null || dio == null) {
        return (success: false, message: "That code doesn't look right");
      }

      final response = await dio.put(
        '/me/source',
        data: {
          'source': code,
          'method': 'invite_code',
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(keyInviteCodeSet, true);
        return (success: true, message: 'Invite code applied!');
      } else {
        return (success: false, message: "That code doesn't look right");
      }
    } on DioException catch (e) {
      // Surface meaningful backend error messages (e.g. "Invalid invite code",
      // "You cannot use your own invite code") from 400 responses.
      // Spring Boot serializes ResponseStatusException as:
      //   {"timestamp":...,"status":400,"error":"Bad Request","message":"...","path":"..."}
      if (e.response?.statusCode == 400) {
        final body = e.response?.data;
        String? serverMsg;
        if (body is String && body.isNotEmpty) {
          serverMsg = body;
        } else if (body is Map) {
          final msg = body['message'];
          if (msg is String && msg.isNotEmpty) serverMsg = msg;
        }
        debugPrint('[AcquisitionService] Invite code rejected by server: $serverMsg');
        return (success: false, message: serverMsg ?? "That code doesn't look right");
      }
      debugPrint('[AcquisitionService] Error submitting invite code: $e');
      return (success: false, message: "That code doesn't look right");
    } catch (e) {
      debugPrint('[AcquisitionService] Error submitting invite code: $e');
      return (success: false, message: "That code doesn't look right");
    }
  }

  /// Reports first message milestone after a Firestore send succeeds.
  /// Fire-and-forget; retried on next send if it failed.
  Future<void> reportFirstMessageMilestone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyReported = prefs.getBool(keyFirstMessageReported) ?? false;
      if (alreadyReported) {
        return;
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final token = await currentUser.getIdToken();
      final dio = _dio;
      if (token == null || dio == null) return;

      debugPrint('[AcquisitionService] Reporting first message milestone...');
      final response = await dio.post(
        '/me/milestones/first-message',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[AcquisitionService] First message milestone marked successfully.');
        await prefs.setBool(keyFirstMessageReported, true);
      }
    } catch (e) {
      debugPrint('[AcquisitionService] Failed to report first message milestone (will retry on next send): $e');
      // Do not mark flag, so it will retry on next send
    }
  }
}
