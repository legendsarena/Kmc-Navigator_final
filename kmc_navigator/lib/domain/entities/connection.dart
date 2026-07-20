/// Represents a directed or bidirectional link between two [Location]s.
///
/// Connections form the graph that [RoutingService] traverses to
/// generate step-by-step directions, e.g. "Corridor A links Reception
/// to Staircase 1". Every field beyond the two endpoint ids is optional
/// admin-authored metadata the routing engine uses to weight the graph
/// and phrase natural-language instructions — none of it is hardcoded
/// in Dart; it all comes from Firestore.
class Connection {
  const Connection({
    required this.id,
    required this.fromLocationId,
    required this.toLocationId,
    this.instruction,
    this.distanceMeters,
    this.estimatedSeconds,
    this.landmark,
    this.stairType,
    this.floorChange,
    this.directionPriority,
    this.isBidirectional = true,
    this.isActive = true,
  });

  final String id;
  final String fromLocationId;
  final String toLocationId;

  /// Admin-authored step instruction, e.g. "Turn left after the
  /// pharmacy". When absent, [RoutingService] generates one from
  /// [directionPriority] / [floorChange] / [stairType] instead.
  final String? instruction;

  /// Physical distance this edge covers, in meters. Used as the primary
  /// Dijkstra edge weight and to estimate walking time / step count.
  final double? distanceMeters;

  /// Admin-authored walking time for this edge, in seconds. Preferred
  /// over a distance-based estimate when present (e.g. to account for a
  /// slow staircase).
  final int? estimatedSeconds;

  /// A notable nearby landmark to mention in the generated instruction,
  /// e.g. "the pharmacy" or "the reception desk".
  final String? landmark;

  /// Type of staircase this edge represents, if it's a vertical
  /// transition, e.g. "Main Entrance Staircase". Null for same-floor
  /// edges.
  final String? stairType;

  /// Whether this edge changes floors. When null, [RoutingService]
  /// derives it by comparing the two locations' `floorId`s instead —
  /// this field lets an admin override that (e.g. a ramp that looks
  /// like a floor change but isn't).
  final bool? floorChange;

  /// A turn hint used to auto-generate an instruction when [instruction]
  /// isn't set, e.g. "left", "right", "straight".
  final String? directionPriority;

  /// Whether a visitor can walk this edge in both directions. When
  /// true, the routing graph adds an edge in both directions using the
  /// same metadata.
  final bool isBidirectional;

  /// Soft-delete flag — inactive connections are excluded when building
  /// the routing graph, without needing to actually delete the document.
  final bool isActive;

  factory Connection.fromFirestore(Map<String, dynamic> data, String id) {
    return Connection(
      id: id,
      fromLocationId: (data['fromLocationId'] as String?) ?? '',
      toLocationId: (data['toLocationId'] as String?) ?? '',
      instruction: data['instruction'] as String?,
      // Accepts both the current schema key and the legacy Prompt #3
      // key, so nothing already written to Firestore breaks.
      distanceMeters: ((data['distanceInMeters'] ?? data['distanceMeters']) as num?)?.toDouble(),
      estimatedSeconds: (data['estimatedSeconds'] as num?)?.toInt(),
      landmark: data['landmark'] as String?,
      stairType: data['stairType'] as String?,
      floorChange: data['floorChange'] as bool?,
      directionPriority: data['directionPriority'] as String?,
      isBidirectional: ((data['bidirectional'] ?? data['isBidirectional']) as bool?) ?? true,
      isActive: (data['isActive'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fromLocationId': fromLocationId,
      'toLocationId': toLocationId,
      'instruction': instruction,
      'distanceInMeters': distanceMeters,
      'estimatedSeconds': estimatedSeconds,
      'landmark': landmark,
      'stairType': stairType,
      'floorChange': floorChange,
      'directionPriority': directionPriority,
      'bidirectional': isBidirectional,
      'isActive': isActive,
    };
  }

  Connection copyWith({
    String? id,
    String? fromLocationId,
    String? toLocationId,
    String? instruction,
    double? distanceMeters,
    int? estimatedSeconds,
    String? landmark,
    String? stairType,
    bool? floorChange,
    String? directionPriority,
    bool? isBidirectional,
    bool? isActive,
  }) {
    return Connection(
      id: id ?? this.id,
      fromLocationId: fromLocationId ?? this.fromLocationId,
      toLocationId: toLocationId ?? this.toLocationId,
      instruction: instruction ?? this.instruction,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      estimatedSeconds: estimatedSeconds ?? this.estimatedSeconds,
      landmark: landmark ?? this.landmark,
      stairType: stairType ?? this.stairType,
      floorChange: floorChange ?? this.floorChange,
      directionPriority: directionPriority ?? this.directionPriority,
      isBidirectional: isBidirectional ?? this.isBidirectional,
      isActive: isActive ?? this.isActive,
    );
  }
}
