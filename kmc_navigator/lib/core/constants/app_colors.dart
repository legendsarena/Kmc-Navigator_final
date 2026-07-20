import 'package:flutter/material.dart';

/// Centralized color palette for KMC Navigator.
///
/// The app uses a calm, clinical blue-and-white palette that feels
/// trustworthy and easy to read inside a hospital environment.
class AppColors {
  AppColors._(); // Prevent instantiation.

  // --- Brand / primary ---
  static const Color primaryBlue = Color(0xFF1565C0); // Main brand blue
  static const Color primaryBlueDark = Color(0xFF0D47A1);
  static const Color primaryBlueLight = Color(0xFF64B5F6);

  // --- Surfaces ---
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEDF2FA);

  // --- Text ---
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // --- Status / semantic ---
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF0288D1);

  // --- Misc ---
  static const Color divider = Color(0xFFE0E4EA);
  static const Color disabled = Color(0xFFBDBDBD);

  // --- Wayfinding accents ---
  // Used for the step-by-step route "path line" and its connector dots —
  // deliberately restricted to the blue family so the palette stays true
  // to the "Blue / White / Light Grey" brief.
  static const Color pathLine = Color(0xFFBBD8F5);
  static const Color pathLineActive = primaryBlue;

  // Soft tint backgrounds for icon badges (roughly 10% primary over white).
  static const Color primaryTint = Color(0xFFE8F1FC);
  static const Color successTint = Color(0xFFE6F4EA);

  /// Hero gradient used on the Splash and Home headers.
  static const List<Color> heroGradient = [primaryBlueDark, primaryBlue];
}
