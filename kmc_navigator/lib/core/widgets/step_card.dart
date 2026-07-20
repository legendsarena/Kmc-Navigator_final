import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// A single row in the step-by-step directions timeline.
///
/// This is the app's signature wayfinding element: each instruction sits
/// beside a numbered badge, and badges are joined by a vertical line —
/// literally tracing the walking path down the screen. Numbering is
/// appropriate here (unlike decorative "01/02/03" labels elsewhere)
/// because these steps really are an ordered sequence a person follows.
/// The final step is highlighted to make "you've arrived" unmistakable.
class StepCard extends StatelessWidget {
  const StepCard({
    super.key,
    required this.stepNumber,
    required this.instruction,
    required this.icon,
    required this.showTopConnector,
    required this.showBottomConnector,
    this.isDestination = false,
  });

  final int stepNumber;
  final String instruction;
  final IconData icon;
  final bool showTopConnector;
  final bool showBottomConnector;
  final bool isDestination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color badgeColor = isDestination ? AppColors.success : AppColors.primaryBlue;
    final Color badgeTint = isDestination ? AppColors.successTint : AppColors.primaryTint;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Connector column: line + numbered badge ---
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Expanded(
                  child: showTopConnector
                      ? Container(width: 2, color: AppColors.pathLine)
                      : const SizedBox(),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: badgeTint,
                    shape: BoxShape.circle,
                    border: Border.all(color: badgeColor, width: 2),
                  ),
                  child: Center(
                    child: isDestination
                        ? Icon(Icons.flag_rounded, size: 18, color: badgeColor)
                        : Text(
                            '$stepNumber',
                            style: theme.textTheme.titleSmall?.copyWith(color: badgeColor),
                          ),
                  ),
                ),
                Expanded(
                  child: showBottomConnector
                      ? Container(width: 2, color: AppColors.pathLine)
                      : const SizedBox(),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          // --- Instruction card ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
              child: Card(
                margin: EdgeInsets.zero,
                color: isDestination ? AppColors.successTint : AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    children: [
                      Icon(icon, color: badgeColor, size: AppSizes.iconSizeSm + 2),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          instruction,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isDestination ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
