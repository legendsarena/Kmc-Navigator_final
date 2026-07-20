/// Centralized, human-readable strings used across the app.
///
/// Keeping strings here (instead of scattered as literals) makes future
/// localization and copy edits straightforward.
class AppStrings {
  AppStrings._();

  static const String appName = 'KMC Navigator';
  static const String appTagline = 'Navigate Kottayam Medical College with ease.';
  static const String hospitalName = 'Kottayam Medical College';

  // Splash
  static const String splashLoading = 'Loading hospital map...';

  // Home
  static const String homeTitle = 'KMC Navigator';
  static const String homeGetDirections = 'Get Directions';
  static const String homeSearchDepartment = 'Search Department';
  static const String homeAnnouncements = 'Announcements';

  // Route
  static const String routeTitle = 'Directions';
  static const String routeSelectStart = 'Select current location';
  static const String routeSelectDestination = 'Select destination';

  // Search
  static const String searchTitle = 'Search';
  static const String searchHint = 'Search department or room';

  // Announcements
  static const String announcementTitle = 'Announcements';
  static const String announcementEmpty = 'No announcements yet';

  // About
  static const String aboutTitle = 'About';

  // Help
  static const String helpTitle = 'Help';

  // Admin
  static const String adminLoginTitle = 'Admin Login';
  static const String adminDashboardTitle = 'Admin Dashboard';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String loginButton = 'Login';

  // Generic
  static const String comingSoon = 'Coming soon';
  static const String placeholderScreenNote =
      'This screen is a structural placeholder. Functionality will be added in a later step.';
}
