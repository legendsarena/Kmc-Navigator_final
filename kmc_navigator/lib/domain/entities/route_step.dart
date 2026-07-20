/// A single, ready-to-display instruction in a calculated route.
///
/// Produced by `domain/routing/route_step_generator.dart` from a graph
/// edge ([Connection]) — this is the "human-friendly" output the UI
/// actually renders, so the presentation layer never needs to look at
/// raw graph/connection data.
class RouteStep {
  const RouteStep({
    required this.instruction,
    required this.fromLocationId,
    required this.toLocationId,
    this.distanceMeters,
    this.isFloorChange = false,
    this.isDestination = false,
    this.landmark,
  });

  final String instruction;
  final String fromLocationId;
  final String toLocationId;
  final double? distanceMeters;

  /// True when walking this step moves the visitor to a different floor
  /// (e.g. taking a staircase).
  final bool isFloorChange;

  /// True for the final step in a route — the "you've arrived" step.
  final bool isDestination;

  final String? landmark;
}
