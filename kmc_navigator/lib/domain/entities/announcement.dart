import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp, FieldValue;

/// Represents a hospital-wide announcement shown to visitors, e.g.
/// "OP Block lift under maintenance" or "New department opened".
///
/// This is the one entity that imports `cloud_firestore` directly — only
/// for the [Timestamp] value type, so `createdAt` round-trips correctly
/// through Firestore. No Firestore instance/collection APIs are used
/// here; that stays confined to the data layer.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.message,
    this.createdAt,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String message;
  final DateTime? createdAt;
  final bool isActive;

  factory Announcement.fromFirestore(Map<String, dynamic> data, String id) {
    final dynamic rawCreatedAt = data['createdAt'];
    return Announcement(
      id: id,
      title: (data['title'] as String?) ?? '',
      message: (data['message'] as String?) ?? '',
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : null,
      isActive: (data['isActive'] as bool?) ?? true,
    );
  }

  /// Converts this entity into a Firestore-ready map.
  ///
  /// Uses [FieldValue.serverTimestamp] when [createdAt] hasn't been set
  /// locally yet, so new announcements are timestamped by the server
  /// (avoids clock-skew issues across admin devices) rather than the
  /// client clock.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'isActive': isActive,
    };
  }

  Announcement copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
