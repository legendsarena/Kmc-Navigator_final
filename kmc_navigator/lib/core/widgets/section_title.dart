import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

/// A consistent section heading used to introduce a group of content
/// (e.g. "Quick Actions", "Step-by-step Directions"). Optionally shows
/// a trailing action such as "See all".
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.trailingLabel,
    this.onTrailingTap,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSizes.md),
  });

  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (trailingLabel != null)
            TextButton(
              onPressed: onTrailingTap,
              child: Text(trailingLabel!),
            ),
        ],
      ),
    );
  }
}
