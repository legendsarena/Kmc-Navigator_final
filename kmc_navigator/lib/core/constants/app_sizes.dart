/// Centralized spacing, radius, and sizing tokens.
///
/// Using a small fixed scale keeps the UI visually consistent and makes
/// responsive tweaks (tablet vs phone) easy to manage from one place.
class AppSizes {
  AppSizes._();

  // Spacing scale (multiples of 4).
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Border radius.
  static const double radiusSm = 8;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusPill = 999;

  // Component sizing.
  static const double buttonHeight = 52;
  static const double iconSizeSm = 20;
  static const double iconSizeMd = 28;
  static const double iconSizeLg = 40;
  static const double cardElevation = 1.5;

  // Breakpoints for simple responsive layout decisions.
  static const double breakpointTablet = 600;
  static const double breakpointDesktop = 1024;
}
