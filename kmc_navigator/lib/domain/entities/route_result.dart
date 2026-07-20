import 'location.dart';
import 'route_step.dart';

/// The complete output of a routing calculation between two locations.
///
/// Built by `RoutingService.calculateRoute()` from a shortest-path graph
/// traversal — nothing in this class knows how the path was found, it's
/// purely the display-ready result the UI consumes.
class RouteResult {
  const RouteResult({
    required this.locations,
    required this.steps,
    required this.totalDistanceMeters,
    required this.estimatedWalkingTime,
    required this.floorChangeCount,
    required this.startingFloor,
    required this.destinationFloor,
    required this.visitedLocationIds,
  });

  /// Every location visited along the path, in order — first entry is
  /// the starting location, last is the destination.
  final List<Location> locations;

  /// Natural-language directions, one per graph edge traveled, plus a
  /// final "you've arrived" step.
  final List<RouteStep> steps;

  final double totalDistanceMeters;
  final Duration estimatedWalkingTime;

  /// How many times the path crosses from one floor to another.
  final int floorChangeCount;

  final String? startingFloor;
  final String? destinationFloor;

  /// Location ids in traversal order — the same information as
  /// [locations] but as raw ids, useful for analytics/debugging without
  /// needing the full entities.
  final List<String> visitedLocationIds;

  Location get origin => locations.first;
  Location get destination => locations.last;

  /// Whether the walk crosses at least one floor.
  bool get hasFloorChange => floorChangeCount > 0;
}
