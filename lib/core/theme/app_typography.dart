import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Headings - Inter (Modern / Clean)
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.1,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.2,
      );

  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  // Body - Inter
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );
}
