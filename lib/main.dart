import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/onboarding/basics/basics_screen.dart';

void main() {
  runApp(const ProviderScope(child: JiffyApp()));
}

class JiffyApp extends StatelessWidget {
  const JiffyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jiffy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const BasicsScreen(),
    );
  }
}
