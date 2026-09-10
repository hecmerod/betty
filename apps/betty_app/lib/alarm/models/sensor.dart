enum SensorType {
  motion('motion', 'Sensor de Movimiento', 'motion_sensor_rounded'),
  doorClaraboyas('door_claraboyas', 'Puertas Claraboyas', 'door_front'),
  doorTrasera('door_trasera', 'Puerta Trasera', 'door_back'),
  doorLateral('door_lateral', 'Puerta Lateral', 'door_sliding'),
  doorDelanteras('door_delanteras', 'Puertas Delanteras', 'meeting_room'),
  location('location', 'Ubicación GPS', 'location_on');

  final String id;
  final String displayName;
  final String iconName;

  const SensorType(this.id, this.displayName, this.iconName);

  static SensorType fromId(String id) {
    return SensorType.values.firstWhere((type) => type.id == id, orElse: () => SensorType.motion);
  }
}

class Sensor {
  final SensorType type;
  final bool isListening;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Sensor({required this.type, required this.isListening, this.createdAt, this.updatedAt});

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      type: SensorType.fromId(json['id'] as String),
      isListening: json['isListening'] as bool,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': type.id,
      'isListening': isListening,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Sensor copyWith({SensorType? type, bool? isListening, DateTime? createdAt, DateTime? updatedAt}) {
    return Sensor(
      type: type ?? this.type,
      isListening: isListening ?? this.isListening,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
