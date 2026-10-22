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
    return SensorType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => SensorType.motion,
    );
  }
}
