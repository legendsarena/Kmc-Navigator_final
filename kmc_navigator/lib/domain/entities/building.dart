/// Represents a physical building on the hospital campus.
///
/// V1 only ever contains a single building ("Medical OP Building"), but
/// modeling it as an entity keeps the app extensible to future buildings
/// without reshaping the data layer later.
///
/// Serialization is Map-based (not tied to `cloud_firestore`'s
/// `DocumentSnapshot`) so this entity has no Firebase SDK dependency —
/// the data layer is responsible for calling `doc.data()` and passing
/// the resulting `Map` + `doc.id` in here.
class Building {
  const Building({
    required this.id,
    required this.name,
    this.description,
    this.floorCount = 0,
  });

  final String id;
  final String name;
  final String? description;
  final int floorCount;

  /// Builds a [Building] from a Firestore document's decoded data and id.
  factory Building.fromFirestore(Map<String, dynamic> data, String id) {
    return Building(
      id: id,
      name: (data['name'] as String?) ?? '',
      description: data['description'] as String?,
      floorCount: (data['floorCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converts this entity into a Firestore-ready map. The document id is
  /// intentionally excluded — it's supplied separately (as the doc path)
  /// when writing.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'floorCount': floorCount,
    };
  }

  Building copyWith({
    String? id,
    String? name,
    String? description,
    int? floorCount,
  }) {
    return Building(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      floorCount: floorCount ?? this.floorCount,
    );
  }
}
