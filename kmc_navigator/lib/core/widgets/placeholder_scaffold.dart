import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';

/// A shared scaffold used by every "not yet implemented" screen in the
/// foundation build.
///
/// Each real screen (Route, Search, Announcements, Admin, etc.) wraps its
/// content with this so navigation, app bar styling, and the "coming soon"
/// notice stay consistent until the feature is built out in a later step.
class PlaceholderScaffold extends StatelessWidget {
  const PlaceholderScaffold({
    super.key,
    required this.title,
    required this.icon,
    this.actions,
  });

  final String title;
  final IconData icon;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSizes.iconSizeLg * 1.5, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppSizes.md),
              Text(
                AppStrings.comingSoon,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                AppStrings.placeholderScreenNote,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
