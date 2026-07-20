import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/routing_service.dart';
import '../../domain/entities/route_result.dart';
import 'repository_providers.dart';

/// [RoutingService] depends on the location/connection repositories, so
/// it's built here (rather than in `service_providers.dart`) once those
/// are available. `ref.onDispose` cancels its Firestore listeners when
/// this provider is torn down.
final routingServiceProvider = Provider<RoutingService>((ref) {
  final service = RoutingService(
    locationRepository: ref.watch(locationRepositoryProvider),
    connectionRepository: ref.watch(connectionRepositoryProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// The single door the presentation layer has into route calculation.
///
/// Screens do exactly two things with this: `ref.watch` it to render
/// loading/error/data via [AsyncValueWidget], and
/// `ref.read(routeControllerProvider.notifier).calculateRoute(...)` to
/// kick a calculation off. Nothing about graphs, Dijkstra, or Firestore
/// is visible from here — that's entirely inside [RoutingService].
class RouteController extends AsyncNotifier<RouteResult?> {
  @override
  FutureOr<RouteResult?> build() {
    // No route has been requested yet when this controller is first
    // created — Route screen triggers the first real calculation.
    return null;
  }

  /// Calculates the route between two locations and updates [state]
  /// with the result (or the friendly [AppFailure] if it fails).
  Future<void> calculateRoute({
    required String fromLocationId,
    required String toLocationId,
  }) async {
    state = const AsyncValue.loading();
    final service = ref.read(routingServiceProvider);
    state = await AsyncValue.guard(
      () => service.calculateRoute(fromLocationId: fromLocationId, toLocationId: toLocationId),
    );
  }

  /// Clears any previously calculated route — used when leaving the
  /// Route screen so a stale result doesn't flash on the next visit.
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final routeControllerProvider = AsyncNotifierProvider<RouteController, RouteResult?>(
  RouteController.new,
);
