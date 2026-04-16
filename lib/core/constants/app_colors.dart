import 'dart:ui';

/// Centralized color palette for LandlordOS.
///
/// Refined for a premium proptech / fintech aesthetic.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF4338CA);
  static const secondary = Color(0xFF059669);
  static const error = Color(0xFFDC2626);
  static const accent = Color(0xFFF59E0B);

  // Light theme
  static const backgroundLight = Color(0xFFFAFAF9);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const onBackgroundLight = Color(0xFF1A1A18);

  // Dark theme
  static const backgroundDark = Color(0xFF18181B);
  static const surfaceDark = Color(0xFF27272A);
  static const onBackgroundDark = Color(0xFFF8F7F4);

  // Neutral
  static const border = Color(0x26000000);
  static const divider = Color(0x1A000000);
  static const disabled = Color(0xFF9E9E9E);

  // Status
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF2563EB);
}
