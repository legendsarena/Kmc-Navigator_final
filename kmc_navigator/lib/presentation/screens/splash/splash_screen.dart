import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';

/// First screen shown on app launch.
///
/// Displays the KMC Navigator mark, name, and tagline with a gentle
/// entrance animation, then moves on to Home. Later this will also
/// verify Firebase initialization / check for an active admin session
/// before deciding where to route.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _markScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
  );

  late final Animation<double> _textFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
  );

  late final Animation<Offset> _textSlide = Tween<Offset>(
    begin: const Offset(0, 0.15),
    end: Offset.zero,
  ).animate(_textFade);

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // TODO(next-prompt): replace fixed delay with real Firebase/init checks.
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) context.goNamed(RouteNames.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.heroGradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Logo mark placeholder ---
                ScaleTransition(
                  scale: _markScale,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.explore_rounded,
                      size: 60,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        Text(
                          AppStrings.appName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                          child: Text(
                            AppStrings.appTagline,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xxl),
                FadeTransition(
                  opacity: _textFade,
                  child: const _PulsingDots(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A minimal three-dot loading animation, deliberately understated so it
/// reads as "please wait a moment" rather than a busy spinner.
class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final double t = (_controller.value - (i * 0.2)) % 1.0;
            final double opacity = 0.35 + 0.65 * (0.5 - (t - 0.5).abs()) * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity.clamp(0.35, 1.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
