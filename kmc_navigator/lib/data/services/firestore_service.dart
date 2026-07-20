import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/admin.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/connection.dart';
import '../../domain/entities/location.dart';

/// Wraps all Cloud Firestore access for the app.
///
/// Exposes strongly-typed collection references (via `withConverter`) so
/// repositories work directly with domain entities instead of raw
/// `Map<String, dynamic>` — the entity's own `fromFirestore`/
/// `toFirestore` methods do the translation in one place.
///
/// Collections: `buildings`, `locations`, `connections`, `announcements`,
/// `admins` — matching the V1 Firestore schema. `floors` is intentionally
/// not included yet (see `domain/entities/floor.dart`).
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Building> get buildings => _firestore
      .collection('buildings')
      .withConverter<Building>(
        fromFirestore: (snap, _) => Building.fromFirestore(snap.data() ?? {}, snap.id),
        toFirestore: (value, _) => value.toFirestore(),
      );

  CollectionReference<Location> get locations => _firestore
      .collection('locations')
      .withConverter<Location>(
        fromFirestore: (snap, _) => Location.fromFirestore(snap.data() ?? {}, snap.id),
        toFirestore: (value, _) => value.toFirestore(),
      );

  CollectionReference<Connection> get connections => _firestore
      .collection('connections')
      .withConverter<Connection>(
        fromFirestore: (snap, _) => Connection.fromFirestore(snap.data() ?? {}, snap.id),
        toFirestore: (value, _) => value.toFirestore(),
      );

  CollectionReference<Announcement> get announcements => _firestore
      .collection('announcements')
      .withConverter<Announcement>(
        fromFirestore: (snap, _) => Announcement.fromFirestore(snap.data() ?? {}, snap.id),
        toFirestore: (value, _) => value.toFirestore(),
      );

  CollectionReference<Admin> get admins => _firestore
      .collection('admins')
      .withConverter<Admin>(
        fromFirestore: (snap, _) => Admin.fromFirestore(snap.data() ?? {}, snap.id),
        toFirestore: (value, _) => value.toFirestore(),
      );
}
