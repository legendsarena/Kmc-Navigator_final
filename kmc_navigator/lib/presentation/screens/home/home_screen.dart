import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/department_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/searchable_selector_field.dart';
import '../../../core/widgets/section_title.dart';
import '../../../domain/entities/building.dart';
import '../../../domain/entities/location.dart';
import '../../providers/data_providers.dart';
import '../route/route_screen.dart';

/// Main landing screen shown after splash.
///
/// Lets a visitor pick a building, their current location, and a
/// destination, then jump into step-by-step directions. Quick-action
/// tiles below give one-tap access to Announcements, About, and Help.
///
/// Building and location options are loaded live from Firestore via
/// [buildingsProvider] / [locationsProvider] — the selection itself
/// (which building/location is currently picked) still lives as local
/// widget state, since it's a transient in-session choice, not data
/// that needs to be persisted anywhere.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Building? _selectedBuilding;
  Location? _currentLocation;
  Location? _destination;

  void _onFindRoute() {
    if (_currentLocation == null || _destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your current location and destination.')),
      );
      return;
    }
    if (_currentLocation!.id == _destination!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your current location and destination are the same.')),
      );
      return;
    }
    context.pushNamed(
      RouteNames.route,
      extra: RouteSelection(
        current: _currentLocation!,
        destination: _destination!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(buildingsProvider);
    final locationsAsync = ref.watch(locationsProvider);

    // Keep the locally-selected building valid as the live list arrives
    // or changes (e.g. defaults to the first building once loaded).
    final List<Building> buildings = buildingsAsync.valueOrNull ?? const [];
    if (_selectedBuilding == null && buildings.isNotEmpty) {
      _selectedBuilding = buildings.first;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HomeHeader(onAdminTap: () => context.goNamed(RouteNames.adminLogin))),
          SliverToBoxAdapter(
            child: Transform.translate(
              // Pulls the selector panel up so it slightly overlaps the
              // curved hero header, tying the two sections together.
              offset: const Offset(0, -28),
              child: _buildSelectorPanel(buildingsAsync, locationsAsync),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(title: 'Quick Actions'),
                  const SizedBox(height: AppSizes.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: DepartmentCard(
                            icon: Icons.campaign_rounded,
                            label: AppStrings.homeAnnouncements,
                            onTap: () => context.pushNamed(RouteNames.announcements),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: DepartmentCard(
                            icon: Icons.info_outline_rounded,
                            label: AppStrings.aboutTitle,
                            onTap: () => context.pushNamed(RouteNames.about),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: DepartmentCard(
                            icon: Icons.help_outline_rounded,
                            label: AppStrings.helpTitle,
                            onTap: () => context.pushNamed(RouteNames.help),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Buildings drive whether the panel renders at all (loading/error/
  /// data) — locations are allowed to still be loading/empty underneath
  /// since the location pickers already show their own "No matches"
  /// state gracefully for an empty list.
  Widget _buildSelectorPanel(
    AsyncValue<List<Building>> buildingsAsync,
    AsyncValue<List<Location>> locationsAsync,
  ) {
    return buildingsAsync.when(
      data: (buildings) => _SelectorPanel(
        building: _selectedBuilding,
        buildings: buildings,
        onBuildingSelected: (v) => setState(() => _selectedBuilding = v),
        locations: (locationsAsync.valueOrNull ?? const []).where((l) => l.isActive).toList(),
        currentLocation: _currentLocation,
        onCurrentLocationSelected: (v) => setState(() => _currentLocation = v),
        destination: _destination,
        onDestinationSelected: (v) => setState(() => _destination = v),
        onFindRoute: _onFindRoute,
      ),
      loading: () => const _SelectorPanelSkeleton(),
      error: (error, _) => _SelectorPanelError(
        failure: AppFailure.from(error),
        onRetry: () => ref.invalidate(buildingsProvider),
      ),
    );
  }
}

/// The curved, gradient hero header at the top of Home: app name,
/// hospital name, and a discreet admin entry point.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onAdminTap});

  final VoidCallback onAdminTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.sm, AppSizes.md, AppSizes.xxl + AppSizes.md),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppSizes.radiusLg)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.homeTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.hospitalName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Admin',
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
              onPressed: onAdminTap,
            ),
          ],
        ),
      ),
    );
  }
}

/// The floating white panel with the building / location / destination
/// selectors and the "Find Route" call to action.
class _SelectorPanel extends StatelessWidget {
  const _SelectorPanel({
    required this.building,
    required this.buildings,
    required this.onBuildingSelected,
    required this.locations,
    required this.currentLocation,
    required this.onCurrentLocationSelected,
    required this.destination,
    required this.onDestinationSelected,
    required this.onFindRoute,
  });

  final Building? building;
  final List<Building> buildings;
  final ValueChanged<Building> onBuildingSelected;
  final List<Location> locations;
  final Location? currentLocation;
  final ValueChanged<Location> onCurrentLocationSelected;
  final Location? destination;
  final ValueChanged<Location> onDestinationSelected;
  final VoidCallback onFindRoute;

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchableSelectorField<Building>(
            label: 'Building',
            icon: Icons.apartment_rounded,
            options: buildings,
            labelOf: (b) => b.name,
            selected: building,
            sheetTitle: 'Select Building',
            hintText: buildings.isEmpty ? 'No buildings available yet' : 'Tap to select',
            onSelected: onBuildingSelected,
          ),
          const SizedBox(height: AppSizes.sm),
          SearchableSelectorField<Location>(
            label: 'Current Location',
            icon: Icons.my_location_rounded,
            options: locations,
            labelOf: (l) => l.name,
            subtitleOf: (l) => l.category ?? 'Location',
            selected: currentLocation,
            sheetTitle: 'Select Current Location',
            hintText: 'Where are you now?',
            onSelected: onCurrentLocationSelected,
          ),
          const SizedBox(height: AppSizes.sm),
          SearchableSelectorField<Location>(
            label: 'Destination',
            icon: Icons.flag_rounded,
            options: locations,
            labelOf: (l) => l.name,
            subtitleOf: (l) => l.category ?? 'Location',
            selected: destination,
            sheetTitle: 'Select Destination',
            hintText: 'Where do you want to go?',
            onSelected: onDestinationSelected,
          ),
          const SizedBox(height: AppSizes.md),
          PrimaryButton(
            label: 'Find Route',
            icon: Icons.directions_walk_rounded,
            onPressed: onFindRoute,
          ),
        ],
      ),
    );
  }
}

/// A calm loading placeholder shown in place of the selector panel while
/// [buildingsProvider] is still connecting to Firestore.
class _SelectorPanelSkeleton extends StatelessWidget {
  const _SelectorPanelSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar() => Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        );

    return _PanelShell(
      child: Column(
        children: [
          bar(),
          const SizedBox(height: AppSizes.sm),
          bar(),
          const SizedBox(height: AppSizes.sm),
          bar(),
          const SizedBox(height: AppSizes.md),
          Container(
            height: AppSizes.buttonHeight,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown in place of the selector panel if the buildings stream fails
/// (e.g. no internet, permission denied).
class _SelectorPanelError extends StatelessWidget {
  const _SelectorPanelError({required this.failure, required this.onRetry});

  final AppFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.textSecondary, size: 36),
          const SizedBox(height: AppSizes.sm),
          Text(failure.title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(failure.message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.md),
          PrimaryButton(label: 'Try again', icon: Icons.refresh_rounded, onPressed: onRetry),
        ],
      ),
    );
  }
}

/// Shared white, rounded, elevated card shell used by the selector panel
/// in all three of its states (data / loading / error).
class _PanelShell extends StatelessWidget {
  const _PanelShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
