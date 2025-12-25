import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryRaspberry,
        onPrimary: AppColors.textPrimary, // White text on primary
        secondary: AppColors.primaryViolet,
        tertiary: AppColors.deepPurple,
        surface: AppColors.textPrimary, // White
        onSurface: AppColors.midnightPlum,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.primaryViolet,
      ),
      scaffoldBackgroundColor: AppColors.textPrimary,
      textTheme: _buildTextTheme(AppColors.midnightPlum),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.midnightPlum),
      ),
      dividerColor: Colors.black12,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: AppColors.primaryRaspberry,
        onPrimary: AppColors.textPrimary,
        secondary: AppColors.primaryViolet,
        tertiary: AppColors.deepPurple,
        surface: AppColors.surfacePlum,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.primaryViolet,
      ),
      scaffoldBackgroundColor: AppColors.midnightPlum,
      textTheme: _buildTextTheme(AppColors.textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      dividerColor: Colors.white12,
    );
  }

  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: baseColor),
      displayMedium: AppTypography.displayMedium.copyWith(color: baseColor),
      displaySmall: AppTypography.displaySmall.copyWith(color: baseColor),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: baseColor),
      bodyMedium: AppTypography.bodyMedium
          .copyWith(color: baseColor.withValues(alpha: 0.8)),
      labelLarge: AppTypography.labelLarge.copyWith(color: baseColor),
    );
  }
}
