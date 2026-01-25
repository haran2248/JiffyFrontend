import 'package:flutter/material.dart';

/// Splash screen shown while checking authentication state.
///
/// This screen is displayed briefly on app startup while Firebase
/// restores the authentication state. It prevents the login screen
/// from flashing before redirecting to the appropriate screen.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Jiffy logo with circular loading indicator
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circular loading indicator around the logo
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  // Jiffy app icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
