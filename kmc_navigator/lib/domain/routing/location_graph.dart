import '../entities/connection.dart';
import '../entities/location.dart';

/// Assumed average indoor walking speed, in meters/second, used to turn
/// a [Connection.distanceMeters] into an estimated travel time when the
/// admin hasn't authored an explicit [Connection.estimatedSeconds].
/// ~1.2 m/s is a common "unhurried indoor walk" pace, allowing for
/// hallway traffic and patients who may walk slower than average.
const double kAverageWalkingSpeedMetersPerSecond = 1.2;

/// A single traversable edge in the routing graph — one direction of a
/// [Connection]. A bidirectional connection produces two [GraphEdge]s
/// (one per direction) sharing the same underlying [connection] data.
class GraphEdge {
  const GraphEdge({required this.toLocationId, required this.connection, required this.weight});

  final String toLocationId;
  final Connection connection;

  /// Dijkstra edge weight — meters when available, otherwise derived
  /// from [Connection.estimatedSeconds], otherwise a small positive
  /// fallback so no edge has zero/negative weight.
  final double weight;
}

/// The result of a successful shortest-path search: an ordered chain of
/// nodes and the edges connecting them.
class RoutePath {
  const RoutePath({required this.nodeIds, required this.edges, required this.totalWeight});

  /// Location ids in traversal order, starting at the source and ending
  /// at the destination. Always `edges.length + 1` entries.
  final List<String> nodeIds;

  /// The connections traveled, in the same order as [nodeIds].
  final List<Connection> edges;

  final double totalWeight;
}

/// An in-memory graph of a building's [Location]s (nodes) and
/// [Connection]s (edges), built once from Firestore data and reused for
/// every route calculation until the underlying data changes.
///
/// This class has no Firebase/Flutter dependency — it's pure graph
/// theory over plain domain entities, which is what makes it directly
/// unit-testable (see `test/domain/routing/location_graph_test.dart`)
/// without mocking Firestore at all.
class LocationGraph {
  LocationGraph._(this._locationsById, this._adjacency);

  final Map<String, Location> _locationsById;
  final Map<String, List<GraphEdge>> _adjacency;

  /// Builds a graph from raw location/connection lists.
  ///
  /// - Inactive locations/connections are excluded entirely.
  /// - Connections referencing a location that doesn't exist (or is
  ///   inactive) are skipped rather than throwing — a single bad admin
  ///   entry shouldn't break routing for the whole building.
  /// - Self-loops (`fromLocationId == toLocationId`) are skipped.
  /// - Bidirectional connections add an edge in both directions.
  factory LocationGraph.build(List<Location> locations, List<Connection> connections) {
    final Map<String, Location> byId = {
      for (final location in locations)
        if (location.isActive) location.id: location,
    };

    final Map<String, List<GraphEdge>> adjacency = {for (final id in byId.keys) id: <GraphEdge>[]};

    for (final connection in connections) {
      if (!connection.isActive) continue;
      if (connection.fromLocationId == connection.toLocationId) continue;
      if (!byId.containsKey(connection.fromLocationId)) continue;
      if (!byId.containsKey(connection.toLocationId)) continue;

      final double weight = _weightOf(connection);
      adjacency[connection.fromLocationId]!.add(
        GraphEdge(toLocationId: connection.toLocationId, connection: connection, weight: weight),
      );
      if (connection.isBidirectional) {
        adjacency[connection.toLocationId]!.add(
          GraphEdge(toLocationId: connection.fromLocationId, connection: connection, weight: weight),
        );
      }
    }

    return LocationGraph._(byId, adjacency);
  }

  static double _weightOf(Connection connection) {
    if (connection.distanceMeters != null && connection.distanceMeters! > 0) {
      return connection.distanceMeters!;
    }
    if (connection.estimatedSeconds != null && connection.estimatedSeconds! > 0) {
      return connection.estimatedSeconds! * kAverageWalkingSpeedMetersPerSecond;
    }
    // Every edge needs a positive weight for Dijkstra to behave; this
    // only kicks in for a connection with no distance/time metadata at
    // all, which shouldn't happen once real hospital data exists.
    return 1.0;
  }

  bool get isEmpty => _locationsById.isEmpty;
  int get nodeCount => _locationsById.length;
  bool hasNode(String locationId) => _locationsById.containsKey(locationId);
  Location? locationOf(String locationId) => _locationsById[locationId];
  List<GraphEdge> edgesFrom(String locationId) => _adjacency[locationId] ?? const [];

  /// Finds the shortest path between [fromId] and [toId] using
  /// Dijkstra's algorithm, weighted by [GraphEdge.weight] (distance in
  /// meters wherever it's available).
  ///
  /// Returns `null` when either node is missing from the graph, or when
  /// no chain of connections links them.
  ///
  /// Implementation note: this is the classic O(V²) array-scan variant
  /// (no binary heap) rather than a priority-queue-based O((V+E) log V)
  /// implementation. For a single hospital building — realistically
  /// dozens to a few hundred locations — that's tens of thousands of
  /// operations at worst, which is instant on a phone. If a future
  /// multi-building campus graph grows into the thousands of nodes,
  /// swap the linear "find minimum" scan below for a binary heap
  /// without changing this method's signature or behavior.
  RoutePath? shortestPath(String fromId, String toId) {
    if (!hasNode(fromId) || !hasNode(toId)) return null;
    if (fromId == toId) {
      return RoutePath(nodeIds: [fromId], edges: const [], totalWeight: 0);
    }

    final Map<String, double> distance = {for (final id in _locationsById.keys) id: double.infinity};
    final Map<String, String?> previousNode = {};
    final Map<String, GraphEdge?> previousEdge = {};
    final Set<String> visited = {};
    distance[fromId] = 0;

    while (visited.length < _locationsById.length) {
      // Pick the unvisited node with the smallest known distance.
      String? current;
      double best = double.infinity;
      for (final id in _locationsById.keys) {
        if (visited.contains(id)) continue;
        final double d = distance[id]!;
        if (d < best) {
          best = d;
          current = id;
        }
      }

      // No reachable unvisited node left — the remaining graph is
      // disconnected from the source.
      if (current == null) break;
      if (current == toId) break;
      visited.add(current);

      for (final edge in edgesFrom(current)) {
        if (visited.contains(edge.toLocationId)) continue;
        final double candidate = distance[current]! + edge.weight;
        if (candidate < (distance[edge.toLocationId] ?? double.infinity)) {
          distance[edge.toLocationId] = candidate;
          previousNode[edge.toLocationId] = current;
          previousEdge[edge.toLocationId] = edge;
        }
      }
    }

    final double? finalDistance = distance[toId];
    if (finalDistance == null || finalDistance.isInfinite) return null;

    // Reconstruct the path by walking backward from the destination.
    final List<String> nodeIds = [toId];
    final List<Connection> edges = [];
    String cursor = toId;
    while (cursor != fromId) {
      final GraphEdge? edge = previousEdge[cursor];
      final String? previous = previousNode[cursor];
      if (edge == null || previous == null) return null; // Should be unreachable.
      edges.add(edge.connection);
      nodeIds.add(previous);
      cursor = previous;
    }

    return RoutePath(
      nodeIds: nodeIds.reversed.toList(),
      edges: edges.reversed.toList(),
      totalWeight: finalDistance,
    );
  }
}
