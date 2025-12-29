import 'package:flutter/material.dart';

class AppColors {
  // Primary (Rich & Premium)
  static const Color primaryRaspberry = Color(0xFFD81B60); // Deep Raspberry
  static const Color primaryViolet = Color(0xFF8E24AA); // Royal Violet

  // Surfaces (Deep & Rich)
  static const Color midnightPlum = Color(0xFF0D0B14); // Main Background
  static const Color noir = Color(0xFF1A1125); // Secondary Bg
  static const Color surfacePlum = Color(0xFF2A1B3D); // Cards/Inputs
  static const Color surfacePlumLight = Color(0xFF3D2A5A); // Lighter variant for elevated surfaces

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0A8BF); // Soft Lavender Gray
  static const Color textSecondaryLight = Color(0xFF6B6578); // Darker gray for light mode readability

  // Accents
  static const Color deepPurple = Color(0xFF4A148C);
  static const Color errorRed = Color(0xFFCF6679);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryRaspberry, primaryViolet],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
