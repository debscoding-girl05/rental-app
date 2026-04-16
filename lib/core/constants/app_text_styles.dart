import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography definitions using Poppins via Google Fonts.
///
/// Poppins is a geometric sans-serif with a modern, premium feel.
/// Weight mapping:
///   Headlines  — w700 (bold)
///   Titles     — w600 (semibold)
///   Body       — w400 (regular)
///   Labels     — w500 (medium)
abstract final class AppTextStyles {
  static TextTheme get textTheme => GoogleFonts.poppinsTextTheme();

  // ── Headlines ──────────────────────────────────────────────

  static TextStyle get headlineLarge => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      );

  // ── Titles ─────────────────────────────────────────────────

  static TextStyle get titleLarge => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMedium => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  // ── Body ───────────────────────────────────────────────────

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  // ── Labels ─────────────────────────────────────────────────

  static TextStyle get labelLarge => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );
}
