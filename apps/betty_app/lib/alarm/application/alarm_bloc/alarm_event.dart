import 'package:betty_app/alarm/domain/sensor_type.dart';
import 'package:equatable/equatable.dart';

abstract class AlarmEvent extends Equatable {
  const AlarmEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlarmStatus extends AlarmEvent {
  const LoadAlarmStatus();
}

class ToggleAlarm extends AlarmEvent {
  const ToggleAlarm();
}

class LoadSensors extends AlarmEvent {
  const LoadSensors();
}

class ToggleSensor extends AlarmEvent {
  final SensorType sensorType;

  const ToggleSensor(this.sensorType);

  @override
  List<Object?> get props => [sensorType];
}

class LoadAlarmPassword extends AlarmEvent {
  const LoadAlarmPassword();
}

class SetAlarmPassword extends AlarmEvent {
  final String password;

  const SetAlarmPassword(this.password);

  @override
  List<Object?> get props => [password];
}
