import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/error_state_widget.dart';
import '../../presentation/providers/data_providers.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../presentation/screens/about/about_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/admin_login_screen.dart';
import '../../presentation/screens/announcement/announcement_screen.dart';
import '../../presentation/screens/help/help_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/route/route_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import 'go_router_refresh_stream.dart';
import 'route_names.dart';

/// Builds a [CustomTransitionPage] with a subtle fade + slide-up motion.
///
/// Applied to every route so navigation feels smooth and consistent
/// without leaning on any platform-default page transition.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Riverpod provider exposing the app's [GoRouter] instance.
///
/// Exposing the router through a provider (rather than a global constant)
/// makes it possible to later inject auth-aware redirect logic that reads
/// from other providers (e.g. an `authStateProvider`) without refactoring
/// call sites.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    // Re-evaluates `redirect` whenever admin auth state changes, so a
    // sign-out immediately kicks the admin off the dashboard instead of
    // waiting for the next manual navigation.
    refreshListenable: GoRouterRefreshStream(ref.watch(authRepositoryProvider).watchAdminAuthState()),
    redirect: (context, state) {
      final bool isAdminDashboard = state.matchedLocation == RouteNames.adminDashboard;
      if (!isAdminDashboard) return null;

      // Only redirect once we have a definitive (non-loading) answer —
      // otherwise a signed-in admin would flash through the login
      // screen on every cold start while the auth stream connects.
      final authState = ref.read(adminAuthStateProvider);
      final bool isSignedInAdmin = authState.asData?.value != null;
      if (authState.isLoading || isSignedInAdmin) return null;
      return RouteNames.adminLogin;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        pageBuilder: (context, state) => _fadePage(state, const SplashScreen()),
      ),
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        pageBuilder: (context, state) => _fadePage(state, const HomeScreen()),
      ),
      GoRoute(
        path: RouteNames.route,
        name: RouteNames.route,
        // `extra` optionally carries the current-location/destination
        // labels chosen on Home, so Route screen can echo the visitor's
        // selection. Falls back to placeholder data when absent (e.g.
        // when this route is opened directly).
        pageBuilder: (context, state) => _fadePage(state, RouteScreen(selection: state.extra as RouteSelection?)),
      ),
      GoRoute(
        path: RouteNames.search,
        name: RouteNames.search,
        pageBuilder: (context, state) => _fadePage(state, const SearchScreen()),
      ),
      GoRoute(
        path: RouteNames.announcements,
        name: RouteNames.announcements,
        pageBuilder: (context, state) => _fadePage(state, const AnnouncementScreen()),
      ),
      GoRoute(
        path: RouteNames.about,
        name: RouteNames.about,
        pageBuilder: (context, state) => _fadePage(state, const AboutScreen()),
      ),
      GoRoute(
        path: RouteNames.help,
        name: RouteNames.help,
        pageBuilder: (context, state) => _fadePage(state, const HelpScreen()),
      ),
      GoRoute(
        path: RouteNames.adminLogin,
        name: RouteNames.adminLogin,
        pageBuilder: (context, state) => _fadePage(state, const AdminLoginScreen()),
      ),
      GoRoute(
        path: RouteNames.adminDashboard,
        name: RouteNames.adminDashboard,
        pageBuilder: (context, state) => _fadePage(state, const AdminDashboardScreen()),
      ),
    ],

    // A calm, friendly fallback instead of a raw Flutter error screen.
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('KMC Navigator')),
      body: ErrorStateWidget(
        title: "Page not found",
        message: "That screen doesn't exist. Let's get you back home.",
        retryLabel: 'Go to Home',
        onRetry: () => context.goNamed(RouteNames.home),
      ),
    ),
  );
});
