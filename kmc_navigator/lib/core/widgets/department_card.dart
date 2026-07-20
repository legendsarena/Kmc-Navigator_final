import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// A compact, centered tile used for grid-style actions — Home screen
/// quick actions (Announcements / About / Help) today, and potentially
/// department shortcuts later.
///
/// Distinct from [LocationCard] (a horizontal list row) — this is a
/// square-ish tappable tile meant to sit in a row or grid.
class DepartmentCard extends StatelessWidget {
  const DepartmentCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.badgeColor = AppColors.primaryTint,
    this.iconColor = AppColors.primaryBlue,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color badgeColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      elevation: AppSizes.cardElevation,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md, horizontal: AppSizes.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: AppSizes.iconSizeMd - 2),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
