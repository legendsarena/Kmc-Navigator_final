import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Professional hospital theme for KMC Navigator.
///
/// Material 3, blue-and-white palette, rounded/modern components, and
/// accessible typography suitable for a wide range of visitors including
/// elderly patients and their families.
///
/// Type pairing: **Manrope** (a geometric, signage-like display face) is
/// used for headings — it reads clearly at a distance the way hospital
/// wayfinding signage does — while **Inter** carries body copy for
/// maximum on-screen legibility at small sizes.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: Brightness.light,
      primary: AppColors.primaryBlue,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    final TextTheme displayFont = GoogleFonts.manropeTextTheme();
    final TextTheme bodyFont = GoogleFonts.interTextTheme();

    final TextTheme textTheme = bodyFont.copyWith(
      displayLarge: displayFont.displayLarge?.copyWith(color: AppColors.textPrimary),
      displayMedium: displayFont.displayMedium?.copyWith(color: AppColors.textPrimary),
      displaySmall: displayFont.displaySmall?.copyWith(color: AppColors.textPrimary),
      headlineLarge: displayFont.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      headlineMedium: displayFont.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineSmall: displayFont.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: displayFont.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleMedium: displayFont.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: displayFont.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: bodyFont.bodyLarge?.copyWith(fontSize: 16, color: AppColors.textPrimary),
      bodyMedium: bodyFont.bodyMedium?.copyWith(fontSize: 14.5, color: AppColors.textSecondary),
      bodySmall: bodyFont.bodySmall?.copyWith(fontSize: 12.5, color: AppColors.textSecondary),
      labelLarge: bodyFont.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,

      // Route-level fade+slide transitions are applied centrally in
      // `app_router.dart` via CustomTransitionPage, so every screen gets
      // the same subtle motion regardless of platform default.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // --- AppBar ---
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),

      // --- Cards: modern, softly rounded ---
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppSizes.cardElevation,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
      ),

      // --- Buttons: rounded, high-contrast, tap-friendly ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // --- Inputs ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),

      // --- Misc ---
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
