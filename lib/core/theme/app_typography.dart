import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Headings - Plus Jakarta Sans (Neon Pulse Design)
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.1,
      );

  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.2,
      );

  static TextStyle get displaySmall => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  // Body - Plus Jakarta Sans
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // Quotes - Lora (Neon Pulse Design)
  static TextStyle get serifQuote => GoogleFonts.lora(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        height: 1.5,
      );
}
