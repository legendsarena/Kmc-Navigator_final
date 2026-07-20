import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Wraps Firebase Cloud Messaging for the app.
///
/// Used to push hospital-wide announcements (e.g. lift outages,
/// department relocations) to visitors' devices. V1 only needs the
/// device to be reachable — there's no per-user targeting since there
/// are no user accounts, so every install subscribes to a shared
/// `announcements` topic.
class NotificationService {
  NotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  static const String announcementsTopic = 'announcements';

  /// Asks the OS for notification permission. Safe to call multiple
  /// times — iOS/Android both no-op if already granted or denied.
  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  /// The device's current FCM registration token, if available.
  Future<String?> getToken() => _messaging.getToken();

  /// Subscribes this device to the shared announcements topic so the
  /// admin can broadcast new announcements without per-device targeting.
  Future<void> subscribeToAnnouncements() => _messaging.subscribeToTopic(announcementsTopic);

  Future<void> unsubscribeFromAnnouncements() => _messaging.unsubscribeFromTopic(announcementsTopic);

  /// Stream of messages received while the app is in the foreground.
  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  /// Performs the app-launch setup: request permission, then subscribe
  /// to announcements. Failures are swallowed (logged in debug only) so
  /// a notification hiccup never blocks the rest of the app from
  /// starting up.
  Future<void> initialize() async {
    try {
      await requestPermission();
      await subscribeToAnnouncements();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('NotificationService.initialize failed: $error');
      }
    }
  }
}
