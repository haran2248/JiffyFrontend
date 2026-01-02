import 'package:flutter/material.dart';

/// Static resend code text with countdown.
///
/// Displays "Resend code in Xs" with the time portion highlighted.
/// This is UI-only - no timer logic.
class ResendCodeText extends StatelessWidget {
  final int seconds;

  const ResendCodeText({
    super.key,
    this.seconds = 26,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        children: [
          const TextSpan(text: 'Resend code in '),
          TextSpan(
            text: '${seconds}s',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
