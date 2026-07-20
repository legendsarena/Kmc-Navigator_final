/// Represents a navigable point of interest inside a [Floor].
///
/// This can be a department, room, landmark (staircase, lift, entrance),
/// or any other point a visitor might select as a start/destination.
/// Every [Location] is a node in the routing graph [RoutingService]
/// builds from Firestore.
class Location {
  const Location({
    required this.id,
    required this.floorId,
    required this.name,
    this.buildingId,
    this.category,
    this.description,
    this.searchKeywords = const [],
    this.isActive = true,
    this.x,
    this.y,
  });

  final String id;

  /// Identifies which floor this location belongs to. Doubles as the
  /// routing engine's "floor" grouping key — comparing two locations'
  /// `floorId`s is how a floor-change edge is detected (see
  /// `domain/routing/location_graph.dart`).
  final String floorId;

  final String name;

  /// Optional building reference, for once V1's single-building
  /// assumption goes away.
  final String? buildingId;

  /// Optional category, e.g. "Department", "Landmark", "Entrance".
  final String? category;
  final String? description;

  /// Extra search terms an admin can attach (synonyms, abbreviations)
  /// so Search matches more than just the exact display name.
  final List<String> searchKeywords;

  /// Soft-delete flag — inactive locations are excluded from the
  /// routing graph and from Search results, without deleting the
  /// document.
  final bool isActive;

  /// Optional map coordinates, reserved for future visual-map support.
  final double? x;
  final double? y;

  factory Location.fromFirestore(Map<String, dynamic> data, String id) {
    return Location(
      id: id,
      floorId: (data['floorId'] as String?) ?? (data['floor'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      buildingId: data['buildingId'] as String?,
      category: data['category'] as String?,
      description: data['description'] as String?,
      searchKeywords: (data['searchKeywords'] as List?)?.whereType<String>().toList() ?? const [],
      isActive: (data['isActive'] as bool?) ?? true,
      x: (data['x'] as num?)?.toDouble(),
      y: (data['y'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'floorId': floorId,
      'name': name,
      'buildingId': buildingId,
      'category': category,
      'description': description,
      'searchKeywords': searchKeywords,
      'isActive': isActive,
      'x': x,
      'y': y,
      // Lower-cased name kept alongside the display name purely to make
      // simple prefix queries possible later (Firestore has no built-in
      // case-insensitive search). Not used for anything yet.
      'nameLowercase': name.toLowerCase(),
    };
  }

  Location copyWith({
    String? id,
    String? floorId,
    String? name,
    String? buildingId,
    String? category,
    String? description,
    List<String>? searchKeywords,
    bool? isActive,
    double? x,
    double? y,
  }) {
    return Location(
      id: id ?? this.id,
      floorId: floorId ?? this.floorId,
      name: name ?? this.name,
      buildingId: buildingId ?? this.buildingId,
      category: category ?? this.category,
      description: description ?? this.description,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      isActive: isActive ?? this.isActive,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}
