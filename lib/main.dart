import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/design_system_page.dart';

void main() {
  runApp(const JiffyApp());
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
      home: const DesignSystemPage(),
    );
  }
}
