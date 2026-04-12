import 'dart:ui';

/// Centralized color palette for LandlordOS.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF3D3A8C);
  static const secondary = Color(0xFF1D9E75);
  static const error = Color(0xFFE24B4A);

  // Light theme
  static const backgroundLight = Color(0xFFF8F7F4);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const onBackgroundLight = Color(0xFF1A1A18);

  // Dark theme
  static const backgroundDark = Color(0xFF1A1A18);
  static const surfaceDark = Color(0xFF2A2A28);
  static const onBackgroundDark = Color(0xFFF8F7F4);

  // Neutral
  static const border = Color(0x26000000);
  static const divider = Color(0x1A000000);
  static const disabled = Color(0xFF9E9E9E);

  // Status
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF9A825);
  static const info = Color(0xFF1565C0);
}
