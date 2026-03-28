import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jiffy/core/auth/auth_viewmodel.dart';
import 'package:jiffy/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class WaitlistScreen extends ConsumerWidget {
  const WaitlistScreen({super.key});

  Future<void> _launchWhatsApp(BuildContext context) async {
    final url = Uri.parse('https://shorturl.at/YuKvo');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch WhatsApp')),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('WaitlistScreen: Error launching WhatsApp: $e');
      debugPrint(stackTrace.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Something went wrong, please try again')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surfacePlum,
              AppColors.surfacePlum.withValues(alpha: 0.8),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Icon or Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRaspberry.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryRaspberry.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.hourglass_empty_rounded,
                    size: 64,
                    color: AppColors.primaryRaspberry,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 40),

                // Title
                Text(
                  "You're on the list!",
                  style: textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                const SizedBox(height: 16),

                // Description
                Text(
                  "Currently, Jiffy is growing one campus at a time. We've added you to our Bangalore waitlist.",
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: 32),

                // Eligibility reminder box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Exclusive Access",
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primaryRaspberry,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _EligibilityItem(
                        icon: Icons.school_outlined,
                        text: "Bangalore College Students",
                      ),
                      const SizedBox(height: 8),
                      const _EligibilityItem(
                        icon: Icons.person_outline,
                        text: "18-30 year olds in Bangalore",
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const Spacer(),

                // WhatsApp Early Access
                Column(
                  children: [
                    Text(
                      "Join our community for early access",
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _launchWhatsApp(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366), // WhatsApp Green
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF25D366)
                                  .withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/whatsapp-icon.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Early Access Group",
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                  ],
                ),

                const SizedBox(height: 32),

                // Back to Login
                const _SignOutButton(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EligibilityItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EligibilityItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 18),
        const SizedBox(width: 10),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final authState = ref.watch(authViewModelProvider);
    final isSigningOut = authState.isSigningOut;

    return TextButton(
      onPressed: isSigningOut
          ? null
          : () async {
              await ref.read(authViewModelProvider.notifier).signOut();
            },
      child: isSigningOut
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              "Back to Login, Sign in with college email if applicable",
              style: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.5),
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
    ).animate().fadeIn(delay: 1000.ms);
  }
}
