import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

/// Terms of service and privacy policy text with entrance animation and clickable links.
class LoginTermsText extends StatelessWidget {
  const LoginTermsText({super.key});

  static const String _termsUrl = 'https://jiffydating.com/terms';
  static const String _privacyUrl = 'https://jiffydating.com/privacy';

  Future<void> _openUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $urlString: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final defaultStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.5),
    );

    final linkStyle = defaultStyle?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.85),
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w500,
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: defaultStyle,
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => _openUrl(_termsUrl),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => _openUrl(_privacyUrl),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 400.ms);
  }
}

