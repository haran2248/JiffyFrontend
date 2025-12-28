import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Terms of service and privacy policy text with entrance animation.
class LoginTermsText extends StatelessWidget {
  const LoginTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      textAlign: TextAlign.center,
      style: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 400.ms);
  }
}
