/// Represents a single floor within a [Building].
///
/// V1 supports exactly three floors inside the Medical OP Building.
/// Not yet backed by its own top-level Firestore collection (the V1
/// schema only defines `buildings`, `locations`, `connections`,
/// `announcements`, and `admins`) — floors are expected to live as a
/// subcollection of their building once real hospital data is added.
/// The (de)serialization methods are provided now so that wiring is a
/// drop-in change later.
class Floor {
  const Floor({
    required this.id,
    required this.buildingId,
    required this.level,
    required this.name,
  });

  final String id;
  final String buildingId;

  /// Numeric level, e.g. 0 = Ground Floor, 1 = First Floor, 2 = Second Floor.
  final int level;

  /// Display name, e.g. "Ground Floor".
  final String name;

  factory Floor.fromFirestore(Map<String, dynamic> data, String id) {
    return Floor(
      id: id,
      buildingId: (data['buildingId'] as String?) ?? '',
      level: (data['level'] as num?)?.toInt() ?? 0,
      name: (data['name'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'buildingId': buildingId,
      'level': level,
      'name': name,
    };
  }

  Floor copyWith({
    String? id,
    String? buildingId,
    int? level,
    String? name,
  }) {
    return Floor(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      level: level ?? this.level,
      name: name ?? this.name,
    );
  }
}
