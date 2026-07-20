import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/kmc_app_bar.dart';

/// Simple "About this app" page: name, version, purpose, and a
/// developer placeholder. Static content only.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const KmcAppBar(title: AppStrings.aboutTitle),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: const Icon(Icons.explore_rounded, size: 46, color: Colors.white),
                ),
                const SizedBox(height: AppSizes.md),
                Text(AppStrings.appName, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Version 1.0.0', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Purpose', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'KMC Navigator helps patients, visitors, and staff find their way around '
                    'the Medical OP Building at Kottayam Medical College. Pick where you are '
                    'and where you need to go, and the app gives you simple, step-by-step '
                    'walking directions — no more wandering hallways or asking around.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What\u2019s in Version 1', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSizes.sm),
                  const _FeatureRow(icon: Icons.apartment_rounded, text: 'Medical OP Building, 3 floors'),
                  const _FeatureRow(icon: Icons.directions_walk_rounded, text: 'Step-by-step walking directions'),
                  const _FeatureRow(icon: Icons.search_rounded, text: 'Searchable department directory'),
                  const _FeatureRow(icon: Icons.campaign_rounded, text: 'Hospital announcements'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryTint,
                    child: Icon(Icons.person_rounded, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Developed by', style: theme.textTheme.bodySmall),
                        Text('Hijaz', style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: AppSizes.sm),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
