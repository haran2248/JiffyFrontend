import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-width primary button for verification screens.
///
/// Features gradient background when enabled, muted state when disabled.
/// Uses Material + InkWell for accessibility.
class VerificationPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isLoading;

  const VerificationPrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled && !isLoading
            ? () {
                if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                  HapticFeedback.lightImpact();
                }
                onTap?.call();
              }
            : null,
        borderRadius: BorderRadius.circular(30),
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEnabled
                  ? [colorScheme.primary, colorScheme.secondary]
                  : [
                      colorScheme.primary.withValues(alpha: 0.4),
                      colorScheme.secondary.withValues(alpha: 0.4),
                    ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: colorScheme.secondary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: textTheme.labelLarge?.copyWith(
                      color: isEnabled
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimary.withValues(alpha: 0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
