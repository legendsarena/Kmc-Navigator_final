import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/admin.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/location.dart';
import 'repository_providers.dart';

/// Live data providers screens actually `watch`. Each wraps a
/// repository stream in a Riverpod [StreamProvider], which gives every
/// consumer built-in loading/error/data states via [AsyncValue] — see
/// `AsyncValueWidget` for how screens render those three states.

/// All buildings (V1: just "Medical OP Building"), ordered by name.
final buildingsProvider = StreamProvider<List<Building>>((ref) {
  return ref.watch(buildingRepositoryProvider).watchBuildings();
});

/// Every location in the building graph, ordered by name. Screens that
/// need a filtered subset (Search, the Home selectors) filter this
/// client-side rather than issuing a new Firestore query per keystroke.
final locationsProvider = StreamProvider<List<Location>>((ref) {
  return ref.watch(locationRepositoryProvider).watchLocations();
});

/// Locations whose name, category, or floor matches [query]
/// (case-insensitive). An empty query returns every location.
///
/// This is what the Search screen and the Home "Current Location" /
/// "Destination" pickers are wired to — typing filters instantly because
/// it's operating on the already-loaded [locationsProvider] snapshot
/// rather than round-tripping to Firestore on every keystroke.
final locationSearchProvider = Provider.family<AsyncValue<List<Location>>, String>((ref, query) {
  final locationsAsync = ref.watch(locationsProvider);
  return locationsAsync.whenData((locations) {
    final active = locations.where((l) => l.isActive).toList();
    if (query.trim().isEmpty) return active;
    final q = query.trim().toLowerCase();
    return active
        .where((location) =>
            location.name.toLowerCase().contains(q) ||
            (location.category?.toLowerCase().contains(q) ?? false) ||
            location.searchKeywords.any((k) => k.toLowerCase().contains(q)))
        .toList();
  });
});

/// Active announcements, newest first.
final announcementsProvider = StreamProvider<List<Announcement>>((ref) {
  return ref.watch(announcementRepositoryProvider).watchAnnouncements();
});

/// The currently signed-in [Admin], or `null` if signed out / not an
/// authorized admin. Drives both the Admin Dashboard's guard redirect
/// and the login screen's loading state.
final adminAuthStateProvider = StreamProvider<Admin?>((ref) {
  return ref.watch(authRepositoryProvider).watchAdminAuthState();
});
