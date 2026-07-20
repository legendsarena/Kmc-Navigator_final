import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

/// A reusable tappable card used for home-screen actions and list items.
///
/// Centralizing the card look keeps the "modern card" visual language
/// consistent everywhere it's used (home actions, search results, etc.).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSizes.md),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
