import 'location.dart';

enum TripStatus {
  inProgress('in_progress'),
  completed('completed');

  final String value;
  const TripStatus(this.value);

  static TripStatus fromString(String value) {
    return TripStatus.values.firstWhere((status) => status.value == value, orElse: () => TripStatus.inProgress);
  }
}

class Trip {
  final String id;
  final String name;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Location>? locations;

  const Trip({
    required this.id,
    required this.name,
    required this.startedAt,
    this.endedAt,
    required this.createdAt,
    required this.updatedAt,
    this.locations,
  });

  TripStatus get status => endedAt != null ? TripStatus.completed : TripStatus.inProgress;

  bool get isInProgress => endedAt == null;

  bool get isCompleted => endedAt != null;

  Duration? get duration => endedAt != null ? endedAt!.difference(startedAt) : null;

  Duration get currentDuration => (endedAt ?? DateTime.now()).difference(startedAt);

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      name: json['name'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      locations: json['locations'] != null
          ? (json['locations'] as List).map((loc) => Location.fromJson(loc as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (locations != null) 'locations': locations!.map((loc) => loc.toJson()).toList(),
    };
  }

  Trip copyWith({
    String? id,
    String? name,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Location>? locations,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      locations: locations ?? this.locations,
    );
  }

  @override
  String toString() {
    return 'Trip(id: $id, name: $name, startedAt: $startedAt, endedAt: $endedAt, status: ${status.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Trip &&
        other.id == id &&
        other.name == name &&
        other.startedAt == startedAt &&
        other.endedAt == endedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        startedAt.hashCode ^
        endedAt.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
