import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';

bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Note: This will fail if GoogleService-Info.plist (iOS) or
    // google-services.json (Android) are missing.
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint(
        'Ensure you have added the Firebase configuration files for your platforms.');
    // We continue so the app still runs, but Firebase features will be disabled
    isFirebaseInitialized = false;
  }

  runApp(const ProviderScope(child: JiffyApp()));
}

class JiffyApp extends ConsumerWidget {
  const JiffyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Jiffy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
