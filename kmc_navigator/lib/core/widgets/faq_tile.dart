import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// A single expandable FAQ entry used on the Help screen.
///
/// Built on [ExpansionTile] but re-skinned to match the app's rounded,
/// card-based visual language rather than the default flat list style.
class FaqTile extends StatelessWidget {
  const FaqTile({super.key, required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Removes the default divider ExpansionTile draws above/below.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.primaryBlue,
          collapsedIconColor: AppColors.textSecondary,
          leading: const Icon(Icons.help_outline_rounded, color: AppColors.primaryBlue),
          title: Text(question, style: theme.textTheme.titleMedium),
          childrenPadding: const EdgeInsets.fromLTRB(AppSizes.lg, 0, AppSizes.lg, AppSizes.md),
          expandedAlignment: Alignment.centerLeft,
          children: [
            Text(answer, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
