import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/announcement_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/building_repository.dart';
import '../../data/repositories/connection_repository.dart';
import '../../data/repositories/location_repository.dart';
import 'service_providers.dart';

/// Repository providers sit between the raw Firebase-backed services
/// (`service_providers.dart`) and the data/state providers screens
/// actually watch (`data_providers.dart`). Screens should never reach
/// past this layer to call `FirestoreService`/`AuthService` directly.

final buildingRepositoryProvider = Provider<BuildingRepository>((ref) {
  return BuildingRepository(ref.watch(firestoreServiceProvider));
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(ref.watch(firestoreServiceProvider));
});

final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  return ConnectionRepository(ref.watch(firestoreServiceProvider));
});

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(ref.watch(firestoreServiceProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(authServiceProvider), ref.watch(firestoreServiceProvider));
});
