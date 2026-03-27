import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'waitlist_service.g.dart';

@riverpod
class WaitlistService extends _$WaitlistService {
  @override
  void build() {}

  Dio get _dio => ref.read(dioProvider);

  /// Notifies the backend that a user has been waitlisted.
  Future<void> notifyWaitlisted(String userId) async {
    try {
      await _dio.post('/api/waitlist', data: {'uid': userId});
      debugPrint(
          'WaitlistService: Notified backend of waitlist for user: $userId');
    } catch (e) {
      debugPrint('WaitlistService: Error notifying backend of waitlist: $e');
    }
  }

  /// Checks the waitlist status of a user from the backend.
  Future<bool> checkWaitlistStatus(String userId) async {
    try {
      final response = await _dio.get(
        '/api/waitlist/status',
        queryParameters: {'uid': userId},
      );
      // Assuming the backend returns the boolean directly as response.data
      // or in a field named 'isWaitlisted'
      if (response.data is bool) {
        return response.data as bool;
      } else if (response.data is Map &&
          response.data.containsKey('isWaitlisted')) {
        return response.data['isWaitlisted'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('WaitlistService: Error checking waitlist status: $e');
      return false;
    }
  }

  /// Returns true if the email is likely a college email based on domain.
  /// (Assumption: any non-gmail.com domain is a college email for now).
  bool isCollegeEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final lowerEmail = email.toLowerCase().trim();
    return !lowerEmail.endsWith('@gmail.com');
  }

  /// Returns true if the user is in the eligible age range (18-25).
  bool isAgeEligible(DateTime? dob) {
    if (dob == null) return false;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age >= 18 && age <= 30;
  }
}
