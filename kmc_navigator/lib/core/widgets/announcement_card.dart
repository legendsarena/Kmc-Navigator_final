import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// A card representing a single hospital announcement: a small tag, a
/// title, a short description, and a relative date.
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.tag,
  });

  final String title;
  final String description;
  final String date;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    tag,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.schedule_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(date, style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(description, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
