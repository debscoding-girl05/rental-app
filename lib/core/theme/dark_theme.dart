import 'package:flutter/material.dart';
import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/constants/app_text_styles.dart';

/// Dark theme for LandlordOS.
///
/// Same premium aesthetic as the light theme, tuned for dark surfaces.
ThemeData buildDarkTheme() {
  final textTheme = AppTextStyles.textTheme.apply(
    bodyColor: AppColors.onBackgroundDark,
    displayColor: AppColors.onBackgroundDark,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // ── Color scheme ───────────────────────────────────────────
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onBackgroundDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // ── Text ───────────────────────────────────────────────────
    textTheme: textTheme,

    // ── App bar ────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.onBackgroundDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.onBackgroundDark,
      ),
    ),

    // ── Cards ──────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
    ),

    // ── Input fields ───────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.onBackgroundDark.withValues(alpha: 0.5),
      ),
      floatingLabelStyle: AppTextStyles.labelLarge.copyWith(
        color: AppColors.primary,
      ),
    ),

    // ── Elevated buttons ───────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        elevation: 0,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    // ── Outlined buttons ───────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 54),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    // ── Chip ───────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      labelStyle: AppTextStyles.labelLarge.copyWith(
        fontSize: 13,
        color: AppColors.onBackgroundDark,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // ── Navigation bar ─────────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primary.withValues(alpha: 0.15),
      labelTextStyle: WidgetStatePropertyAll(
        AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.onBackgroundDark,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.secondary,
      unselectedItemColor: Colors.white.withValues(alpha: 0.5),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // ── Bottom sheet ───────────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
    ),

    // ── Divider ────────────────────────────────────────────────
    dividerColor: Colors.white.withValues(alpha: 0.12),
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.12),
      thickness: 1,
      space: 1,
    ),

    // ── Floating action button ─────────────────────────────────
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // ── Dialog ─────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
    ),
  );
}
