import 'package:betty_app/alarm/domain/sensor_type.dart';
import 'package:equatable/equatable.dart';

class Sensor extends Equatable {
  final SensorType type;
  final bool isListening;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Sensor({
    required this.type,
    required this.isListening,
    this.createdAt,
    this.updatedAt,
  });

  Sensor copyWith({
    SensorType? type,
    bool? isListening,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sensor(
      type: type ?? this.type,
      isListening: isListening ?? this.isListening,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [type, isListening, createdAt, updatedAt];
}
