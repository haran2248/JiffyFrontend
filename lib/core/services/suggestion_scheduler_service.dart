import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'suggestion_scheduler_service.g.dart';

@riverpod
SuggestionSchedulerService suggestionSchedulerService(Ref ref) {
  return SuggestionSchedulerService();
}

class SuggestionSchedulerService {
  static const String _lastFetchKey = 'last_suggestion_fetch_time';
  static const String _nextFetchKey = 'next_suggestion_fetch_time';

  // Random fetch interval: 4 to 12 hours
  static const int _minHours = 4;
  static const int _maxHours = 12;

  final Random _random = Random();

  /// Check if we should fetch new suggestions
  Future<bool> shouldFetchSuggestions() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if it's the first run (no next fetch time set)
    if (!prefs.containsKey(_nextFetchKey)) {
      // First time - fetch immediately
      return true;
    }

    final nextFetchMillis = prefs.getInt(_nextFetchKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    return now >= nextFetchMillis;
  }

  /// Schedule the next fetch time
  Future<void> scheduleNextFetch() async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    await prefs.setInt(_lastFetchKey, now.millisecondsSinceEpoch);

    // Calculate random interval between 4 and 12 hours
    final hours = _minHours + _random.nextInt(_maxHours - _minHours + 1);
    final minutes = _random.nextInt(60);

    final nextFetch = now.add(Duration(hours: hours, minutes: minutes));
    await prefs.setInt(_nextFetchKey, nextFetch.millisecondsSinceEpoch);
  }

  /// Force reset schedule (for testing/debug)
  Future<void> resetSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastFetchKey);
    await prefs.remove(_nextFetchKey);
  }
}
