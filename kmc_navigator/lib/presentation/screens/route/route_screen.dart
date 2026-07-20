import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/kmc_app_bar.dart';
import '../../../core/widgets/step_card.dart';
import '../../../domain/entities/location.dart';
import '../../../domain/entities/route_result.dart';
import '../../../domain/entities/route_step.dart';
import '../../providers/routing_providers.dart';

/// The two locations Home passed along when navigating here — just
/// enough for [RouteScreen] to kick off a real calculation via
/// [RouteController.calculateRoute]. No routing logic lives here or on
/// Home; both only ever deal in location ids.
class RouteSelection {
  const RouteSelection({required this.current, required this.destination});

  final Location current;
  final Location destination;
}

/// Shows the step-by-step walking route between a current location and
/// a destination, calculated live by [RouteController] /
/// [RoutingService].
///
/// This screen's layout is unchanged from Prompt #2/#3 — the same hero
/// summary card and connected step timeline — it now renders a real
/// [RouteResult] instead of mock data, and uses [AsyncValueWidget] to
/// cover loading/error states (same pattern as Search/Announcements).
class RouteScreen extends ConsumerStatefulWidget {
  const RouteScreen({super.key, this.selection});

  final RouteSelection? selection;

  @override
  ConsumerState<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends ConsumerState<RouteScreen> {
  @override
  void initState() {
    super.initState();
    final selection = widget.selection;
    if (selection != null) {
      // Deferred to a microtask so we're not mutating provider state
      // during this widget's own initState/build pass.
      Future.microtask(
        () => ref.read(routeControllerProvider.notifier).calculateRoute(
              fromLocationId: selection.current.id,
              toLocationId: selection.destination.id,
            ),
      );
    }
  }

  @override
  void dispose() {
    // Clears the result so returning to Route screen for a *different*
    // pair of locations never briefly shows the previous route.
    ref.read(routeControllerProvider.notifier).reset();
    super.dispose();
  }

  void _retry() {
    final selection = widget.selection;
    if (selection == null) return;
    ref.read(routeControllerProvider.notifier).calculateRoute(
          fromLocationId: selection.current.id,
          toLocationId: selection.destination.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selection == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const KmcAppBar(title: 'Directions'),
        body: EmptyStateWidget(
          icon: Icons.directions_walk_rounded,
          title: 'No route selected',
          message: 'Pick a current location and destination from Home to see directions.',
          actionLabel: 'Go to Home',
          onAction: () => context.canPop() ? context.pop() : context.goNamed(RouteNames.home),
        ),
      );
    }

    final routeAsync = ref.watch(routeControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const KmcAppBar(title: 'Directions'),
      body: AsyncValueWidget<RouteResult?>(
        value: routeAsync,
        loadingMessage: 'Calculating the best route...',
        onRetry: _retry,
        data: (result) {
          if (result == null) {
            // Still waiting on the first calculateRoute() call to land.
            return const SizedBox.shrink();
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: AppSizes.xl),
            children: [
              _RouteSummaryCard(result: result),
              const SizedBox(height: AppSizes.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Text(
                  'Step-by-step directions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: _StepTimeline(steps: result.steps),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Card summarizing current location → destination, plus the estimated
/// walking time and floor information badges.
class _RouteSummaryCard extends StatelessWidget {
  const _RouteSummaryCard({required this.result});

  final RouteResult result;

  static String _formatDuration(Duration duration) {
    final minutes = (duration.inSeconds / 60).ceil().clamp(1, 999);
    return '$minutes min walk';
  }

  String get _floorLabel {
    if (!result.hasFloorChange || result.startingFloor == result.destinationFloor) {
      return result.startingFloor ?? 'Same floor';
    }
    return '${result.startingFloor} \u2192 ${result.destinationFloor}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _EndpointLabel(
                  icon: Icons.my_location_rounded,
                  label: 'From',
                  value: result.origin.name,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.xs),
                child: Icon(Icons.arrow_forward_rounded, color: Colors.white70),
              ),
              Expanded(
                child: _EndpointLabel(
                  icon: Icons.flag_rounded,
                  label: 'To',
                  value: result.destination.name,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _InfoBadge(
                  icon: Icons.timer_outlined,
                  label: _formatDuration(result.estimatedWalkingTime),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _InfoBadge(icon: Icons.layers_rounded, label: _floorLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EndpointLabel extends StatelessWidget {
  const _EndpointLabel({
    required this.icon,
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: alignEnd ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Icon(icon, size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders live [RouteStep]s as a connected, numbered timeline using
/// [StepCard] — see that widget's doc comment for the design rationale.
/// The icon per step is a display-only choice made here from the step's
/// text/metadata; it has no bearing on route calculation.
class _StepTimeline extends StatelessWidget {
  const _StepTimeline({required this.steps});

  final List<RouteStep> steps;

  static IconData _iconFor(RouteStep step) {
    if (step.isDestination) return Icons.flag_rounded;
    if (step.isFloorChange) return Icons.stairs_rounded;
    final text = step.instruction.toLowerCase();
    if (text.contains('left')) return Icons.turn_left_rounded;
    if (text.contains('right')) return Icons.turn_right_rounded;
    return Icons.straight_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        return StepCard(
          stepNumber: index + 1,
          instruction: step.instruction,
          icon: _iconFor(step),
          showTopConnector: index != 0,
          showBottomConnector: index != steps.length - 1,
          isDestination: step.isDestination,
        );
      }),
    );
  }
}
