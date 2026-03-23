import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/core/theme/app_colors.dart';
import '../../../widgets/button.dart';

class CoPilotIntroScreen extends StatelessWidget {
  const CoPilotIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Dark background from mockup
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            // Simplified logo (three dots)
            SizedBox(
              width: 24,
              height: 24,
              child: Stack(
                children: [
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRaspberry,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    left: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color:
                            AppColors.primaryRaspberry.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRaspberry,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Jiffy",
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.primaryRaspberry,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline,
              size: 18,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    Text(
                      "Deeper than",
                      style: textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                        height: 1.0,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                    // "the Swipe" with glow
                    Text(
                      "the Swipe",
                      style: textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primaryRaspberry,
                        letterSpacing: -1,
                        height: 1.0,
                        shadows: [
                          BoxShadow(
                            color: AppColors.primaryRaspberry
                                .withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideY(begin: 0.1),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      "Stop scrolling, start connecting. A\ndating experience that actually\nunderstands your vibe.",
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                    const SizedBox(height: 48),

                    // The Two Cards Row
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card 1: AI Layer
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.bolt,
                              iconColor: AppColors.primaryRaspberry,
                              title: "The AI Layer",
                              description:
                                  "Neural engine maps your vibe to curate matches that click instantly.",
                              delay: 300.ms,
                              bottomWidget: const _SoundWaveViz(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Card 2: Moments
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.auto_awesome,
                              iconColor: const Color(
                                  0xFFAEA1FF), // Light purple sparkles
                              title: "Moments",
                              description:
                                  "Connections happen organically through stories, not static profiles.",
                              delay: 400.ms,
                              bottomWidget: const _AvatarsViz(),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.all(24),
              child: Button(
                text: "Got It",
                onTap: () {
                  context.replaceRoute(AppRoutes.onboardingProfileSetup);
                },
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feature Card Widget
// ---------------------------------------------------------------------------

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Duration delay;
  final Widget bottomWidget;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.delay,
    required this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF222222), // Dark card background
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF111111), // Even darker circle
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 20),
          // Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const Spacer(),
          const SizedBox(height: 24),
          // Bottom visualization placeholder
          bottomWidget,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Abstract Visualizations for the cards
// ---------------------------------------------------------------------------

class _SoundWaveViz extends StatelessWidget {
  const _SoundWaveViz();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _bar(12, AppColors.primaryRaspberry.withValues(alpha: 0.3)),
          _bar(20, AppColors.primaryRaspberry.withValues(alpha: 0.5)),
          _bar(28, AppColors.primaryRaspberry),
          _bar(18, AppColors.primaryRaspberry.withValues(alpha: 0.5)),
          _bar(12, AppColors.primaryRaspberry.withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  Widget _bar(double height, Color color) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _AvatarsViz extends StatelessWidget {
  const _AvatarsViz();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _avatarPlaceholder(const Color(0xFF8E909B), Icons.person,
                leftOffset: 0),
          ),
          Positioned(
            left: 20,
            child: _avatarPlaceholder(const Color(0xFFFFD1A9), Icons.face,
                isForeground: true),
          ),
          Positioned(
            left: 45,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF5A537A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF222222), width: 2),
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(Color bgColor, IconData icon,
      {bool isForeground = false, double leftOffset = 0}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF222222), width: 2),
      ),
      child: Center(
        child: Icon(icon, color: Colors.black.withValues(alpha: 0.3), size: 24),
      ),
    );
  }
}
