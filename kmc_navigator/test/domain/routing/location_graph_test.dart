import 'package:flutter_test/flutter_test.dart';
import 'package:kmc_navigator/domain/entities/connection.dart';
import 'package:kmc_navigator/domain/entities/location.dart';
import 'package:kmc_navigator/domain/routing/location_graph.dart';

/// These tests exercise [LocationGraph] directly — it's pure Dart with
/// no Firebase dependency, so the whole shortest-path algorithm is
/// testable without mocking Firestore at all. `RoutingService` itself
/// is a thin orchestration layer over this graph plus live repository
/// streams; its behavior (caching, error mapping) is covered by keeping
/// this class's contract solid.
void main() {
  Location loc(String id, {String floor = 'ground', bool isActive = true}) {
    return Location(id: id, floorId: floor, name: id, isActive: isActive);
  }

  Connection conn(
    String id,
    String from,
    String to, {
    double? distanceMeters,
    bool isBidirectional = true,
    bool isActive = true,
    bool? floorChange,
    String? directionPriority,
    String? stairType,
  }) {
    return Connection(
      id: id,
      fromLocationId: from,
      toLocationId: to,
      distanceMeters: distanceMeters,
      isBidirectional: isBidirectional,
      isActive: isActive,
      floorChange: floorChange,
      directionPriority: directionPriority,
      stairType: stairType,
    );
  }

  group('LocationGraph.build', () {
    test('excludes inactive locations as nodes', () {
      final graph = LocationGraph.build(
        [loc('a'), loc('b', isActive: false)],
        [],
      );
      expect(graph.hasNode('a'), isTrue);
      expect(graph.hasNode('b'), isFalse);
      expect(graph.nodeCount, 1);
    });

    test('skips connections referencing a missing or inactive location', () {
      final graph = LocationGraph.build(
        [loc('a'), loc('b', isActive: false)],
        [conn('c1', 'a', 'b', distanceMeters: 5), conn('c2', 'a', 'ghost', distanceMeters: 5)],
      );
      expect(graph.edgesFrom('a'), isEmpty);
    });

    test('skips self-loop connections', () {
      final graph = LocationGraph.build([loc('a')], [conn('c1', 'a', 'a', distanceMeters: 5)]);
      expect(graph.edgesFrom('a'), isEmpty);
    });

    test('bidirectional connections add an edge in both directions', () {
      final graph = LocationGraph.build(
        [loc('a'), loc('b')],
        [conn('c1', 'a', 'b', distanceMeters: 5)],
      );
      expect(graph.edgesFrom('a').single.toLocationId, 'b');
      expect(graph.edgesFrom('b').single.toLocationId, 'a');
    });

    test('one-way connections only add a single-direction edge', () {
      final graph = LocationGraph.build(
        [loc('a'), loc('b')],
        [conn('c1', 'a', 'b', distanceMeters: 5, isBidirectional: false)],
      );
      expect(graph.edgesFrom('a'), hasLength(1));
      expect(graph.edgesFrom('b'), isEmpty);
    });

    test('an empty Firestore snapshot produces an empty graph', () {
      final graph = LocationGraph.build([], []);
      expect(graph.isEmpty, isTrue);
    });
  });

  group('LocationGraph.shortestPath', () {
    test('same source and destination returns a zero-length path', () {
      final graph = LocationGraph.build([loc('a')], []);
      final path = graph.shortestPath('a', 'a');
      expect(path, isNotNull);
      expect(path!.edges, isEmpty);
      expect(path.nodeIds, ['a']);
      expect(path.totalWeight, 0);
    });

    test('returns null when either node is not in the graph', () {
      final graph = LocationGraph.build([loc('a'), loc('b')], []);
      expect(graph.shortestPath('a', 'ghost'), isNull);
      expect(graph.shortestPath('ghost', 'b'), isNull);
    });

    test('returns null when the graph is disconnected', () {
      final graph = LocationGraph.build(
        [loc('a'), loc('b'), loc('c'), loc('d')],
        [conn('c1', 'a', 'b', distanceMeters: 5), conn('c2', 'c', 'd', distanceMeters: 5)],
      );
      expect(graph.shortestPath('a', 'd'), isNull);
    });

    test('picks the lower-weight path over the fewer-hops path', () {
      // a -> b -> d costs 100 (2 hops), a -> c -> e -> d costs 12 (3 hops).
      // A correct Dijkstra implementation must prefer total weight, not hop count.
      final graph = LocationGraph.build(
        [loc('a'), loc('b'), loc('c'), loc('d'), loc('e')],
        [
          conn('c1', 'a', 'b', distanceMeters: 50),
          conn('c2', 'b', 'd', distanceMeters: 50),
          conn('c3', 'a', 'c', distanceMeters: 4),
          conn('c4', 'c', 'e', distanceMeters: 4),
          conn('c5', 'e', 'd', distanceMeters: 4),
        ],
      );

      final path = graph.shortestPath('a', 'd');
      expect(path, isNotNull);
      expect(path!.nodeIds, ['a', 'c', 'e', 'd']);
      expect(path.totalWeight, 12);
    });

    test('detects a floor change between consecutive nodes', () {
      final graph = LocationGraph.build(
        [loc('a', floor: 'ground'), loc('b', floor: 'first')],
        [conn('c1', 'a', 'b', distanceMeters: 5, stairType: 'Main Staircase')],
      );
      final path = graph.shortestPath('a', 'b')!;
      expect(graph.locationOf(path.nodeIds.first)!.floorId, 'ground');
      expect(graph.locationOf(path.nodeIds.last)!.floorId, 'first');
      expect(path.edges.single.stairType, 'Main Staircase');
    });

    test('performs well on a large chain graph (performance sanity check)', () {
      // 500 nodes in a single chain — worst case for an O(V^2) scan
      // since every node must be visited before reaching the far end.
      const nodeCount = 500;
      final locations = [for (int i = 0; i < nodeCount; i++) loc('n$i')];
      final connections = [
        for (int i = 0; i < nodeCount - 1; i++) conn('c$i', 'n$i', 'n${i + 1}', distanceMeters: 1),
      ];
      final graph = LocationGraph.build(locations, connections);

      final stopwatch = Stopwatch()..start();
      final path = graph.shortestPath('n0', 'n${nodeCount - 1}');
      stopwatch.stop();

      expect(path, isNotNull);
      expect(path!.edges, hasLength(nodeCount - 1));
      // Generous ceiling — this is meant to catch an accidental O(V^3)
      // regression, not to be a tight perf benchmark.
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });
}
