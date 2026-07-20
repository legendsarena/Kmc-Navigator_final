import '../../core/errors/app_failure.dart';
import '../../domain/entities/location.dart';
import '../services/firestore_service.dart';

/// Read/write access to the `locations` collection — departments, rooms,
/// and landmarks that visitors can pick as a start/destination or find
/// via Search.
class LocationRepository {
  LocationRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  /// Live stream of every location, ordered by name.
  ///
  /// Filtering for the Search screen and the Home selectors happens
  /// client-side against this stream (see `locationSearchProvider`) —
  /// Firestore doesn't support case-insensitive substring queries, and
  /// V1's location count is small enough that a full live list is cheap
  /// to keep in memory and filter instantly as the person types.
  Stream<List<Location>> watchLocations() async* {
    try {
      yield* _firestoreService.locations
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  /// Live stream of locations belonging to a single floor.
  Stream<List<Location>> watchLocationsByFloor(String floorId) async* {
    try {
      yield* _firestoreService.locations
          .where('floorId', isEqualTo: floorId)
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Future<void> saveLocation(Location location) async {
    try {
      await _firestoreService.locations.doc(location.id).set(location);
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Future<void> deleteLocation(String id) async {
    try {
      await _firestoreService.locations.doc(id).delete();
    } catch (error) {
      throw AppFailure.from(error);
    }
  }
}
