import 'package:flutter/material.dart';

/// Helper class for story text overlay colors
/// Maps spec colors to Material/Flutter colors
/// Following the spec: White, Black, Pink, Purple, Blue, Green, Yellow, Red
class StoryOverlayColors {
  // Spec colors as defined in Stories_tech_spec.md
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color pink = Color(0xFFEC4899); // Close to AppColors.primaryRaspberry
  static const Color purple = Color(0xFFA855F7); // Close to AppColors.primaryViolet
  static const Color blue = Color(0xFF3B82F6);
  static const Color green = Color(0xFF10B981);
  static const Color yellow = Color(0xFFFBBF24);
  static const Color red = Color(0xFFEF4444);

  /// List of all available overlay colors (8 colors as per spec)
  static const List<Color> allColors = [
    white,
    black,
    pink,
    purple,
    blue,
    green,
    yellow,
    red,
  ];

  /// Get color by index (0-7)
  static Color getByIndex(int index) {
    if (index >= 0 && index < allColors.length) {
      return allColors[index];
    }
    return white; // Default
  }
}

