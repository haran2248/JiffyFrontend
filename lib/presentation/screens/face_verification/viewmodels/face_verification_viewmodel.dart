import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:jiffy/core/network/dio_provider.dart';
import 'package:jiffy/core/services/face_verification_service.dart';
import '../models/face_verification_state.dart';

part 'face_verification_viewmodel.g.dart';

/// Similarity threshold for face matching (95%)
const double kSimilarityThreshold = 95.0;

/// S3 bucket URL for user images
const String kS3BucketUrl =
    'https://jiffystorebucket.s3.ap-south-1.amazonaws.com/';

/// ViewModel for face verification flow.
///
/// Manages:
/// - FaceSDK initialization
/// - Reference image loading from S3
/// - Face capture via camera
/// - Face matching
/// - Backend verification status update
@riverpod
class FaceVerificationViewModel extends _$FaceVerificationViewModel {
  late final FaceSDK _faceSDK;

  @override
  FaceVerificationState build() {
    _faceSDK = FaceSDK.instance;
    _initialize();
    return const FaceVerificationState(isLoading: true);
  }

  /// Get the current user's UID from Firebase Auth.
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Get Dio instance from provider (has correct base URL configured)
  Dio get _dio => ref.read(dioProvider);

  /// Initialize the SDK and load reference image.
  Future<void> _initialize() async {
    try {
      await _faceSDK.initialize();
      if (!ref.exists(faceVerificationViewModelProvider)) return;
      state = state.copyWith(isSdkInitialized: true);

      await _loadReferenceImage();
      if (!ref.exists(faceVerificationViewModelProvider)) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('FaceVerificationViewModel: Initialization error - $e');
      if (!ref.exists(faceVerificationViewModelProvider)) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize face verification',
      );
    }
  }

  /// Load user's profile image as reference for matching.
  Future<void> _loadReferenceImage() async {
    final uid = _uid;
    if (uid == null) {
      if (!ref.exists(faceVerificationViewModelProvider)) return;
      state = state.copyWith(errorMessage: 'User not authenticated');
      return;
    }

    try {
      // Fetch user data from API using the app's configured Dio (has base URL)
      debugPrint('FaceVerificationViewModel: Fetching user data for uid: $uid');
      final userResponse = await _dio.get(
        '/api/users/getUser',
        queryParameters: {'uid': uid},
      );
      if (!ref.exists(faceVerificationViewModelProvider)) return;

      final userData = userResponse.data as Map<String, dynamic>?;
      if (userData == null) {
        state = state.copyWith(errorMessage: 'User data not found');
        return;
      }

      final firstImageId = userData['firstImageId'] as String?;

      if (firstImageId == null || firstImageId.isEmpty) {
        state = state.copyWith(errorMessage: 'No profile photo available');
        return;
      }

      // Download reference image from S3 (using separate Dio with timeouts, not the API one)
      final imageUrl = '$kS3BucketUrl$firstImageId';
      debugPrint('FaceVerificationViewModel: Loading image from $imageUrl');

      final s3Dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ));
      final response = await s3Dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (!ref.exists(faceVerificationViewModelProvider)) return;

      if (response.statusCode == 200 && response.data != null) {
        state = state.copyWith(
          referenceImage: Uint8List.fromList(response.data!),
        );
        debugPrint(
            'FaceVerificationViewModel: Reference image loaded successfully');
      } else {
        state = state.copyWith(errorMessage: 'Failed to load profile photo');
      }
    } catch (e) {
      debugPrint(
          'FaceVerificationViewModel: Error loading reference image - $e');
      if (!ref.exists(faceVerificationViewModelProvider)) return;
      state = state.copyWith(errorMessage: 'Failed to load profile photo: $e');
    }
  }

  /// Capture user's face using the camera and match against reference.
  Future<void> captureAndMatch() async {
    if (!state.canCapture) return;

    state = state.copyWith(
      isMatching: true,
      clearError: true,
      clearResult: true,
      clearCapturedImage: true,
    );

    try {
      // Capture face using SDK
      final captureResponse = await _faceSDK.startFaceCapture(
        config: FaceCaptureConfig(
          cameraPositionAndroid: 0,
          cameraPositionIOS: CameraPosition.FRONT,
          cameraSwitchEnabled: true,
        ),
      );

      if (captureResponse.image?.image == null) {
        state = state.copyWith(
          isMatching: false,
          errorMessage: 'Face capture cancelled',
        );
        return;
      }

      final capturedImageBytes = captureResponse.image!.image;
      state = state.copyWith(capturedImage: capturedImageBytes);

      // Create match faces request
      final referenceMatchImage = MatchFacesImage(
        state.referenceImage!,
        ImageType.PRINTED,
      );
      final capturedMatchImage = MatchFacesImage(
        capturedImageBytes,
        ImageType.LIVE,
      );

      final request =
          MatchFacesRequest([referenceMatchImage, capturedMatchImage]);
      final response = await _faceSDK.matchFaces(request);

      // Split results by threshold
      final split = await _faceSDK.splitComparedFaces(response.results, 0);
      final matchedFaces = split.matchedFaces;

      if (matchedFaces.isNotEmpty) {
        final similarity = matchedFaces[0].similarity * 100;

        if (similarity >= kSimilarityThreshold) {
          // Success - update backend
          final updated = await _updateVerificationStatus(true);
          if (!updated) {
            state = state.copyWith(
              isMatching: false,
              similarityScore: similarity,
              result: VerificationResult.error,
              errorMessage:
                  'Face matched but failed to update server. Please try again.',
            );
            return;
          }
          state = state.copyWith(
            isMatching: false,
            similarityScore: similarity,
            result: VerificationResult.matched,
          );
        } else {
          state = state.copyWith(
            isMatching: false,
            similarityScore: similarity,
            result: VerificationResult.notMatched,
            errorMessage:
                'Face did not match. Please try again with better lighting.',
          );
        }
      } else {
        state = state.copyWith(
          isMatching: false,
          result: VerificationResult.notMatched,
          errorMessage: 'Could not detect face. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('FaceVerificationViewModel: Match error - $e');
      state = state.copyWith(
        isMatching: false,
        result: VerificationResult.error,
        errorMessage: 'Verification failed. Please try again.',
      );
    }
  }

  /// Update verification status on backend.
  /// Returns true if update succeeded, false otherwise.
  Future<bool> _updateVerificationStatus(bool isVerified) async {
    final uid = _uid;
    if (uid == null) return false;

    try {
      final service = ref.read(faceVerificationServiceProvider);
      return await service.updateVerificationStatus(uid, isVerified);
    } catch (e) {
      debugPrint('FaceVerificationViewModel: Error updating status - $e');
      return false;
    }
  }

  /// Clear error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset state to try again.
  void reset() {
    state = state.copyWith(
      clearCapturedImage: true,
      clearResult: true,
      clearError: true,
    );
  }
}
