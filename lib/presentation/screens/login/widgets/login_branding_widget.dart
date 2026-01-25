import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Displays the app logo, name, and tagline with entrance animations.
class LoginBranding extends StatelessWidget {
  const LoginBranding({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // App logo/icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              'assets/images/app_icon.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        const SizedBox(height: 32),

        // App name
        Text(
          'Jiffy',
          style: textTheme.displayLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

        const SizedBox(height: 8),

        // Tagline
        Text(
          'Find your perfect match',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
      ],
    );
  }
}
