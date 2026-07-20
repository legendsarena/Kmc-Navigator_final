import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges any [Stream] into a [Listenable] that GoRouter's
/// `refreshListenable` can subscribe to.
///
/// Used to make the router re-evaluate its `redirect` callback whenever
/// admin auth state changes (sign-in/sign-out), so a signed-out visitor
/// can't linger on `/admin/dashboard` after their session ends.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
