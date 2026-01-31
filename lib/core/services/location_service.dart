import "package:flutter/foundation.dart";
import "package:geolocator/geolocator.dart";
import "package:dio/dio.dart";
import "package:jiffy/core/auth/auth_repository.dart";

/// Service for fetching and updating user location.
///
/// Handles:
/// - Getting current GPS coordinates
/// - Sending location to backend
/// - Periodic location updates
class LocationService {
  final Dio _dio;
  final AuthRepository _authRepository;

  /// Minimum time between location updates (in minutes)
  static const int _updateIntervalMinutes = 30;

  DateTime? _lastUpdateTime;

  LocationService({
    required Dio dio,
    required AuthRepository authRepository,
  })  : _dio = dio,
        _authRepository = authRepository;

  /// Get current position if location permission is granted.
  /// Returns null if permission denied or location unavailable.
  Future<Position?> getCurrentPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint("[LocationService] Location permission not granted");
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      debugPrint(
          "[LocationService] Got position: ${position.latitude}, ${position.longitude}");
      return position;
    } catch (e) {
      debugPrint("[LocationService] Error getting position: $e");
      return null;
    }
  }

  /// Update user location on the backend.
  /// Returns true if successful, false otherwise.
  Future<bool> updateLocation(double latitude, double longitude) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      debugPrint("[LocationService] No authenticated user");
      return false;
    }

    try {
      await _dio.post(
        "/api/users/updateLocation",
        queryParameters: {
          "uid": user.uid,
          "latitude": latitude,
          "longitude": longitude,
        },
      );
      debugPrint("[LocationService] Location updated successfully");
      _lastUpdateTime = DateTime.now();
      return true;
    } catch (e) {
      debugPrint("[LocationService] Error updating location: $e");
      return false;
    }
  }

  /// Fetch current position and send to backend if needed.
  /// Only updates if enough time has passed since last update.
  Future<void> updateLocationIfNeeded() async {
    // Check if enough time has passed
    if (_lastUpdateTime != null) {
      final elapsed = DateTime.now().difference(_lastUpdateTime!);
      if (elapsed.inMinutes < _updateIntervalMinutes) {
        debugPrint(
            "[LocationService] Skipping update - last update was ${elapsed.inMinutes} minutes ago");
        return;
      }
    }

    final position = await getCurrentPosition();
    if (position != null) {
      await updateLocation(position.latitude, position.longitude);
    }
  }

  /// Force update location regardless of time elapsed.
  /// Use this after permission is granted during onboarding.
  Future<void> forceUpdateLocation() async {
    final position = await getCurrentPosition();
    if (position != null) {
      await updateLocation(position.latitude, position.longitude);
    }
  }
}
