import 'dart:async';

import '../../core/errors/app_failure.dart';
import '../../domain/entities/connection.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/route_result.dart';
import '../../domain/entities/route_step.dart';
import '../../domain/routing/location_graph.dart';
import '../../domain/routing/route_step_generator.dart';
import '../repositories/connection_repository.dart';
import '../repositories/location_repository.dart';

/// Calculates step-by-step walking routes between two locations.
///
/// This is the **only** place in the app that knows a shortest-path
/// algorithm is involved — the presentation layer calls
/// [calculateRoute] and gets back a display-ready [RouteResult] (or a
/// thrown [AppFailure]); everything about graph construction, edge
/// weighting, and Dijkstra's algorithm is an implementation detail
/// owned by this class and `domain/routing/location_graph.dart`.
///
/// ### How the graph stays fresh without hammering Firestore
/// [LocationRepository.watchLocations] and
/// [ConnectionRepository.watchConnections] are both live streams. This
/// service subscribes to both once (in the constructor) and keeps the
/// latest snapshot of each in memory. The graph itself is only rebuilt
/// — from those already-in-memory lists, no network call — the first
/// time it's needed after Firestore data changes. Every other call to
/// [calculateRoute] reuses the cached graph instantly.
class RoutingService {
  RoutingService({
    required LocationRepository locationRepository,
    required ConnectionRepository connectionRepository,
  })  : _locationRepository = locationRepository,
        _connectionRepository = connectionRepository {
    _subscribeToGraphSources();
  }

  final LocationRepository _locationRepository;
  final ConnectionRepository _connectionRepository;

  StreamSubscription<List<Location>>? _locationsSubscription;
  StreamSubscription<List<Connection>>? _connectionsSubscription;

  List<Location>? _latestLocations;
  List<Connection>? _latestConnections;
  LocationGraph? _cachedGraph;

  final Completer<void> _readyCompleter = Completer<void>();
  bool get _hasInitialData => _latestLocations != null && _latestConnections != null;

  void _subscribeToGraphSources() {
    _locationsSubscription = _locationRepository.watchLocations().listen(
      (locations) {
        _latestLocations = locations;
        _cachedGraph = null; // Invalidate — next calculateRoute rebuilds.
        _completeReadyIfPossible();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!_readyCompleter.isCompleted) {
          _readyCompleter.completeError(AppFailure.from(error), stackTrace);
        }
      },
    );

    _connectionsSubscription = _connectionRepository.watchConnections().listen(
      (connections) {
        _latestConnections = connections;
        _cachedGraph = null;
        _completeReadyIfPossible();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!_readyCompleter.isCompleted) {
          _readyCompleter.completeError(AppFailure.from(error), stackTrace);
        }
      },
    );
  }

  void _completeReadyIfPossible() {
    if (_hasInitialData && !_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  Future<LocationGraph> _ensureGraph() async {
    if (!_hasInitialData) {
      // Waits for the first snapshot of both streams. If that first
      // attempt failed (e.g. permission denied, offline), this rethrows
      // the same friendly AppFailure every time until data does arrive.
      await _readyCompleter.future;
    }
    return _cachedGraph ??= LocationGraph.build(_latestLocations!, _latestConnections!);
  }

  /// Calculates the shortest walking route between two locations.
  ///
  /// Throws an [AppFailure] (never a raw exception) for every failure
  /// case the UI needs to explain to a visitor:
  /// - [AppFailure.sameLocation] — `fromLocationId == toLocationId`.
  /// - [AppFailure.emptyGraph] — no locations/connections in Firestore yet.
  /// - [AppFailure.locationNotFound] — either id isn't in the graph.
  /// - [AppFailure.noRouteFound] — both locations exist, but no chain of
  ///   connections links them.
  /// - Any other [AppFailure] — network/permission issues surfaced while
  ///   loading the graph.
  Future<RouteResult> calculateRoute({
    required String fromLocationId,
    required String toLocationId,
  }) async {
    if (fromLocationId == toLocationId) {
      throw AppFailure.sameLocation();
    }

    final LocationGraph graph = await _ensureGraph();

    if (graph.isEmpty) {
      throw AppFailure.emptyGraph();
    }
    if (!graph.hasNode(fromLocationId) || !graph.hasNode(toLocationId)) {
      throw AppFailure.locationNotFound();
    }

    final RoutePath? path = graph.shortestPath(fromLocationId, toLocationId);
    if (path == null || path.edges.isEmpty) {
      throw AppFailure.noRouteFound();
    }

    return _buildResult(graph, path);
  }

  /// Converts a raw [RoutePath] into the display-ready [RouteResult],
  /// summing distance/time and detecting floor transitions along the way.
  RouteResult _buildResult(LocationGraph graph, RoutePath path) {
    final List<Location> locations = [for (final id in path.nodeIds) graph.locationOf(id)!];
    final List<RouteStep> steps = RouteStepGenerator.generate(path, graph);

    double totalDistance = 0;
    double totalSeconds = 0;
    int floorChanges = 0;

    for (final step in steps) {
      final double? distance = step.distanceMeters;
      totalDistance += distance ?? 0;
      totalSeconds += (distance != null && distance > 0)
          ? distance / kAverageWalkingSpeedMetersPerSecond
          : 5; // Small fallback so a distance-less edge still costs *something*.
      if (step.isFloorChange) floorChanges++;
    }

    return RouteResult(
      locations: locations,
      steps: steps,
      totalDistanceMeters: totalDistance,
      estimatedWalkingTime: Duration(seconds: totalSeconds.round().clamp(1, 24 * 60 * 60)),
      floorChangeCount: floorChanges,
      startingFloor: locations.first.floorId,
      destinationFloor: locations.last.floorId,
      visitedLocationIds: path.nodeIds,
    );
  }

  /// Cancels the Firestore listeners this service opened. Called via
  /// `ref.onDispose` when the owning provider is torn down.
  void dispose() {
    _locationsSubscription?.cancel();
    _connectionsSubscription?.cancel();
  }
}
