import '../../core/errors/app_failure.dart';
import '../../domain/entities/connection.dart';
import '../services/firestore_service.dart';

/// Read/write access to the `connections` collection — the graph edges
/// the (future) routing engine will traverse to build step-by-step
/// directions between two locations.
class ConnectionRepository {
  ConnectionRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  /// Live stream of every connection in the building graph.
  Stream<List<Connection>> watchConnections() async* {
    try {
      yield* _firestoreService.connections
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  /// Connections touching a single location, in either direction —
  /// useful once the routing engine needs a location's neighbors.
  Stream<List<Connection>> watchConnectionsForLocation(String locationId) async* {
    try {
      final fromStream = _firestoreService.connections.where('fromLocationId', isEqualTo: locationId).snapshots();
      await for (final snapshot in fromStream) {
        yield snapshot.docs.map((doc) => doc.data()).toList();
      }
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Future<void> saveConnection(Connection connection) async {
    try {
      await _firestoreService.connections.doc(connection.id).set(connection);
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Future<void> deleteConnection(String id) async {
    try {
      await _firestoreService.connections.doc(id).delete();
    } catch (error) {
      throw AppFailure.from(error);
    }
  }
}
