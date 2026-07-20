import '../../core/errors/app_failure.dart';
import '../../domain/entities/building.dart';
import '../services/firestore_service.dart';

/// Read/write access to the `buildings` collection.
///
/// Reads are open to every visitor (no sign-in required); writes are
/// only ever called from admin-authenticated flows in the presentation
/// layer, and are expected to be rejected server-side by Firestore
/// Security Rules if the caller isn't an admin (see `firestore.rules`).
class BuildingRepository {
  BuildingRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  /// Live stream of all buildings, ordered by name.
  Stream<List<Building>> watchBuildings() async* {
    try {
      yield* _firestoreService.buildings
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Future<Building?> getBuilding(String id) async {
    try {
      final doc = await _firestoreService.buildings.doc(id).get();
      return doc.data();
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  /// Creates or overwrites a building document. Intended for the future
  /// Admin Dashboard "Manage Buildings" flow.
  Future<void> saveBuilding(Building building) async {
    try {
      await _firestoreService.buildings.doc(building.id).set(building);
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Future<void> deleteBuilding(String id) async {
    try {
      await _firestoreService.buildings.doc(id).delete();
    } catch (error) {
      throw AppFailure.from(error);
    }
  }
}
