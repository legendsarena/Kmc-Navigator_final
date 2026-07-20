import '../entities/connection.dart';
import '../entities/route_step.dart';
import 'location_graph.dart';

/// Turns a [RoutePath]'s raw graph edges into an ordered list of
/// [RouteStep]s with natural-language instructions.
///
/// Every phrase here is a generic template driven entirely by
/// Firestore-authored [Connection] fields (`instruction`,
/// `directionPriority`, `stairType`, `landmark`, `floorChange`) — there
/// is no hospital-specific text baked into this file. An admin-authored
/// [Connection.instruction] always wins when present; the templates
/// below only fill in when it's missing.
class RouteStepGenerator {
  RouteStepGenerator._();

  /// ~0.7m is a reasonable average adult stride length, used only to
  /// phrase distance as an approximate step count (e.g. "about 14
  /// steps") the way the UI/UX brief asks for — it's a display detail,
  /// not used anywhere in the actual routing math.
  static const double _metersPerStep = 0.7;

  static List<RouteStep> generate(RoutePath path, LocationGraph graph) {
    if (path.edges.isEmpty) return const [];

    final List<RouteStep> steps = [];
    for (int i = 0; i < path.edges.length; i++) {
      final Connection connection = path.edges[i];
      final String fromId = path.nodeIds[i];
      final String toId = path.nodeIds[i + 1];
      final bool isLastEdge = i == path.edges.length - 1;

      final bool floorChange = connection.floorChange ??
          (graph.locationOf(fromId)?.floorId != graph.locationOf(toId)?.floorId);

      steps.add(
        RouteStep(
          instruction: _instructionFor(connection, floorChange: floorChange, isFinal: isLastEdge, graph: graph, toId: toId),
          fromLocationId: fromId,
          toLocationId: toId,
          distanceMeters: connection.distanceMeters,
          isFloorChange: floorChange,
          isDestination: isLastEdge,
          landmark: connection.landmark,
        ),
      );
    }
    return steps;
  }

  static String _instructionFor(
    Connection connection, {
    required bool floorChange,
    required bool isFinal,
    required LocationGraph graph,
    required String toId,
  }) {
    final List<String> parts = [];

    if (connection.instruction != null && connection.instruction!.trim().isNotEmpty) {
      // Admin-authored instruction takes priority verbatim.
      parts.add(connection.instruction!.trim());
    } else if (floorChange) {
      final String stair = connection.stairType?.trim().isNotEmpty == true
          ? connection.stairType!.trim()
          : 'staircase';
      final String? destinationFloor = graph.locationOf(toId)?.floorId;
      parts.add(
        destinationFloor == null || destinationFloor.isEmpty
            ? 'Take the $stair to the next floor.'
            : 'Take the $stair to $destinationFloor.',
      );
    } else if (isFinal) {
      parts.add(_finalArrivalPhrase(connection.directionPriority));
    } else {
      parts.add(_turnPhrase(connection.directionPriority));
    }

    // Append an approximate step count when we have a real distance and
    // the sentence isn't already the "you've arrived" phrasing.
    if (!isFinal && connection.distanceMeters != null && connection.distanceMeters! > 0) {
      final int steps = (connection.distanceMeters! / _metersPerStep).round().clamp(1, 9999);
      parts.add('Walk about $steps steps.');
    }

    if (connection.landmark != null && connection.landmark!.trim().isNotEmpty && !isFinal) {
      parts.add('You\u2019ll pass ${connection.landmark!.trim()}.');
    }

    return parts.join(' ');
  }

  static String _turnPhrase(String? directionPriority) {
    switch (directionPriority?.trim().toLowerCase()) {
      case 'left':
        return 'Turn left.';
      case 'right':
        return 'Turn right.';
      case 'straight':
      case 'forward':
        return 'Continue forward.';
      default:
        return 'Go straight.';
    }
  }

  static String _finalArrivalPhrase(String? directionPriority) {
    switch (directionPriority?.trim().toLowerCase()) {
      case 'left':
        return 'Your destination is on your left.';
      case 'right':
        return 'Your destination is on your right.';
      default:
        return 'Your destination is straight ahead.';
    }
  }
}
