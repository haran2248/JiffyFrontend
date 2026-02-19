import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/service_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';

bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint(
      'Ensure you have added the Firebase configuration files for your platforms.',
    );
    // We continue so the app still runs, but Firebase features will be disabled
    isFirebaseInitialized = false;
  }

  runApp(const ProviderScope(child: JiffyApp()));
}

class JiffyApp extends ConsumerStatefulWidget {
  const JiffyApp({super.key});

  @override
  ConsumerState<JiffyApp> createState() => _JiffyAppState();
}

class _JiffyAppState extends ConsumerState<JiffyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called by Flutter whenever the app's lifecycle state changes.
  ///
  /// We ping [updateLastActive] when the user brings the app to the foreground
  /// (resumed). This is the most reliable "user is active" signal we have.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        ref.read(homeServiceProvider).updateLastActive(uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
