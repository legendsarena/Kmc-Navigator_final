import '../../core/errors/app_failure.dart';
import '../../domain/entities/announcement.dart';
import '../services/firestore_service.dart';

/// Read/write access to the `announcements` collection.
class AnnouncementRepository {
  AnnouncementRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  /// Live stream of active announcements, newest first.
  Stream<List<Announcement>> watchAnnouncements() async* {
    try {
      yield* _firestoreService.announcements
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  /// Creates or overwrites an announcement. Intended for the future
  /// Admin Dashboard "Manage Announcements" flow.
  Future<void> saveAnnouncement(Announcement announcement) async {
    try {
      await _firestoreService.announcements.doc(announcement.id).set(announcement);
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _firestoreService.announcements.doc(id).delete();
    } catch (error) {
      throw AppFailure.from(error);
    }
  }
}
