import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_card.dart';
import '../../providers/data_providers.dart';
import '../../providers/repository_providers.dart';

/// Admin dashboard shown after a successful admin login.
///
/// The management actions below (Buildings, Locations, Connections,
/// Announcements) are still non-functional entry points — building the
/// actual CRUD screens is out of scope for the backend-integration
/// prompt. Sign-out is wired up: it calls [AuthRepository.signOut] and
/// the router's admin-only redirect (see `app_router.dart`) takes care
/// of bouncing back to Home automatically once the auth stream updates.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  static const List<_DashboardItem> _items = [
    _DashboardItem('Buildings', Icons.apartment_rounded),
    _DashboardItem('Floors', Icons.layers_rounded),
    _DashboardItem('Locations', Icons.place_rounded),
    _DashboardItem('Connections', Icons.alt_route_rounded),
    _DashboardItem('Announcements', Icons.campaign_rounded),
  ];

  Future<void> _onLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.goNamed(RouteNames.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminAsync = ref.watch(adminAuthStateProvider);
    final adminEmail = adminAsync.valueOrNull?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminDashboardTitle),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _onLogout(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        children: [
          if (adminEmail != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.sm),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryTint,
                    child: Icon(Icons.person_rounded, color: AppColors.primaryBlue, size: 20),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Signed in as', style: Theme.of(context).textTheme.bodySmall),
                        Text(adminEmail, style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ..._items.map(
            (item) => AppCard(
              onTap: () {
                // TODO(next-prompt): navigate to each management sub-screen.
              },
              child: Row(
                children: [
                  Icon(item.icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Text(item.label, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardItem {
  const _DashboardItem(this.label, this.icon);
  final String label;
  final IconData icon;
}
