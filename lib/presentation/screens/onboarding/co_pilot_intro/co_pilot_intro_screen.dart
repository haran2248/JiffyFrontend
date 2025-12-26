import 'package:flutter/material.dart';
import '../../../widgets/button.dart';
import '../profile_setup/profile_setup_screen.dart';
import 'widgets/feature_item.dart';
import 'widgets/demo_section.dart';

class CoPilotIntroScreen extends StatelessWidget {
  const CoPilotIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "Your Conversation Co-Pilot",
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Helping you break the ice and keep conversations fun and meaningful with thoughtful suggestions and topics.",
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              const FeatureItem(
                icon: Icons.auto_awesome,
                title: "Smart Icebreakers",
                description:
                    "Never be stuck on what to text first. Get suggestions based on shared interests.",
              ),
              const SizedBox(height: 32),
              const FeatureItem(
                icon: Icons.lightbulb_outline,
                title: "Fresh Topics",
                description:
                    "Find common ground with topic ideas based on your interests + insights.",
              ),
              const SizedBox(height: 32),
              const FeatureItem(
                icon: Icons.security,
                title: "You're in Control",
                description:
                    "You choose what you want to send. We only give you the tools to be the best version.",
              ),
              const SizedBox(height: 64),
              const DemoSection(),
              const SizedBox(height: 48),
              Button(
                text: "Got it, Let's Continue",
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const ProfileSetupScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
