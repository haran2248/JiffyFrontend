import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jiffy/presentation/screens/profile_self/viewmodels/profile_self_viewmodel.dart';
import 'models/face_verification_state.dart';
import 'viewmodels/face_verification_viewmodel.dart';

/// Screen for face verification flow.
///
/// Displays reference image, allows user to capture selfie,
/// and shows match result.
class FaceVerificationScreen extends ConsumerWidget {
  const FaceVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(faceVerificationViewModelProvider);
    final viewModel = ref.read(faceVerificationViewModelProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verify Your Profile',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(context, ref, state, viewModel),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    FaceVerificationState state,
    FaceVerificationViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Instructions
                Text(
                  'Match your face with your profile photo',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Reference Image
                _buildImageCard(
                  context: context,
                  title: 'Your Profile Photo',
                  imageBytes: state.referenceImage,
                  screenWidth: screenWidth,
                  isLoading: state.referenceImage == null,
                ),

                const SizedBox(height: 20),

                // Captured Image
                _buildImageCard(
                  context: context,
                  title: 'Your Selfie',
                  imageBytes: state.capturedImage,
                  screenWidth: screenWidth,
                  placeholder: 'Tap button below to capture',
                ),

                const SizedBox(height: 24),

                // Result Badge
                if (state.result != null) _buildResultBadge(context, state),

                // Error Message
                if (state.errorMessage != null &&
                    state.result != VerificationResult.matched)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      state.errorMessage!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // Action Button
        Padding(
          padding: const EdgeInsets.all(24),
          child: _buildActionButton(context, ref, state, viewModel),
        ),
      ],
    );
  }

  Widget _buildImageCard({
    required BuildContext context,
    required String title,
    required Uint8List? imageBytes,
    required double screenWidth,
    bool isLoading = false,
    String? placeholder,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final imageSize = screenWidth * 0.55;

    return Column(
      children: [
        Text(
          title,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colorScheme.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Loading...',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.error_outline,
                              color: colorScheme.error,
                              size: 48,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 48,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            if (placeholder != null) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  placeholder,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultBadge(BuildContext context, FaceVerificationState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMatched = state.result == VerificationResult.matched;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isMatched
            ? Colors.green.withValues(alpha: 0.15)
            : colorScheme.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isMatched ? Colors.green : colorScheme.error,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMatched ? Icons.check_circle : Icons.cancel,
            color: isMatched ? Colors.green : colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            isMatched ? 'Verification Successful!' : 'Verification Failed',
            style: textTheme.titleSmall?.copyWith(
              color: isMatched ? Colors.green : colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    FaceVerificationState state,
    FaceVerificationViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // If verified, show done button
    if (state.result == VerificationResult.matched) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: Material(
          color: Colors.green,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: () {
              // Haptic feedback with platform guard
              if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                HapticFeedback.lightImpact();
              }
              // Invalidate profile viewmodel to refresh verification status
              ref.invalidate(profileSelfViewModelProvider);
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: Text(
                'Done',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Show capture/retry button
    final isDisabled = !state.canCapture || state.isMatching;
    final buttonText = state.isMatching
        ? 'Matching...'
        : state.capturedImage != null
            ? 'Try Again'
            : 'Capture & Match';

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: isDisabled
            ? colorScheme.primary.withValues(alpha: 0.5)
            : colorScheme.primary,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  // Haptic feedback with platform guard
                  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                    HapticFeedback.mediumImpact();
                  }
                  viewModel.captureAndMatch();
                },
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: state.isMatching
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    buttonText,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
