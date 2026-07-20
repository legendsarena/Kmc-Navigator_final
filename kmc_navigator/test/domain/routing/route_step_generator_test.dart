import 'package:flutter_test/flutter_test.dart';
import 'package:kmc_navigator/domain/entities/connection.dart';
import 'package:kmc_navigator/domain/entities/location.dart';
import 'package:kmc_navigator/domain/routing/location_graph.dart';
import 'package:kmc_navigator/domain/routing/route_step_generator.dart';

void main() {
  Location loc(String id, {String floor = 'ground'}) => Location(id: id, floorId: floor, name: id);

  group('RouteStepGenerator', () {
    test('uses the admin-authored instruction verbatim when present', () {
      final graph = LocationGraph.build(
        [loc('a'), loc('b')],
        [
          const Connection(
            id: 'c1',
            fromLocationId: 'a',
            toLocationId: 'b',
            instruction: 'Walk past the pharmacy and turn left.',
          ),
        ],
      );
      final path = graph.shortestPath('a', 'b')!;
      final steps = RouteStepGenerator.generate(path, graph);

      expect(steps, hasLength(1));
      expect(steps.single.instruction, contains('Walk past the pharmacy and turn left.'));
    });

    test('auto-generates a turn phrase from directionPriority when instruction is missing', () {
      final graph = LocationGraph.build(
        [loc('a'), loc('b'), loc('c')],
        [
          const Connection(id: 'c1', fromLocationId: 'a', toLocationId: 'b', directionPriority: 'left'),
          const Connection(id: 'c2', fromLocationId: 'b', toLocationId: 'c', directionPriority: 'right'),
        ],
      );
      final path = graph.shortestPath('a', 'c')!;
      final steps = RouteStepGenerator.generate(path, graph);

      expect(steps[0].instruction, contains('Turn left.'));
      // The final edge is the "arrival" step, so it uses the arrival
      // phrasing rather than a mid-route turn phrase.
      expect(steps[1].instruction, contains('Your destination is on your right.'));
    });

    test('generates a floor-change instruction mentioning the stair type', () {
      final graph = LocationGraph.build(
        [loc('a', floor: 'ground'), loc('b', floor: 'first')],
        [const Connection(id: 'c1', fromLocationId: 'a', toLocationId: 'b', stairType: 'Main Entrance Staircase')],
      );
      final path = graph.shortestPath('a', 'b')!;
      final steps = RouteStepGenerator.generate(path, graph);

      expect(steps.single.isFloorChange, isTrue);
      expect(steps.single.instruction, contains('Main Entrance Staircase'));
    });

    test('marks only the last step as the destination step', () {
      final graph = LocationGraph.build(
        [loc('a'), loc('b'), loc('c')],
        [
          const Connection(id: 'c1', fromLocationId: 'a', toLocationId: 'b'),
          const Connection(id: 'c2', fromLocationId: 'b', toLocationId: 'c'),
        ],
      );
      final path = graph.shortestPath('a', 'c')!;
      final steps = RouteStepGenerator.generate(path, graph);

      expect(steps[0].isDestination, isFalse);
      expect(steps[1].isDestination, isTrue);
    });

    test('appends an approximate step count when distance is known', () {
      final graph = LocationGraph.build(
        [loc('a'), loc('b'), loc('c')],
        [
          const Connection(id: 'c1', fromLocationId: 'a', toLocationId: 'b', distanceMeters: 7),
          const Connection(id: 'c2', fromLocationId: 'b', toLocationId: 'c', distanceMeters: 3),
        ],
      );
      final path = graph.shortestPath('a', 'c')!;
      final steps = RouteStepGenerator.generate(path, graph);

      expect(steps[0].instruction, contains('Walk about'));
      expect(steps[0].instruction, contains('steps.'));
    });

    test('an empty path produces no steps', () {
      final graph = LocationGraph.build([loc('a')], []);
      final path = graph.shortestPath('a', 'a')!;
      expect(RouteStepGenerator.generate(path, graph), isEmpty);
    });
  });
}
