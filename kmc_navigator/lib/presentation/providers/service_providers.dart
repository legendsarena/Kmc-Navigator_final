import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/notification_service.dart';

/// Central place where all data-layer services that have no other
/// dependencies are exposed as Riverpod providers. Screens/widgets
/// should depend on these providers rather than constructing services
/// directly, so services stay swappable (e.g. for testing with fakes).
///
/// `RoutingService` is *not* here — it depends on the location/
/// connection repositories, so it's built in
/// `presentation/providers/routing_providers.dart` instead, alongside
/// the route-calculation controller that wraps it.

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
