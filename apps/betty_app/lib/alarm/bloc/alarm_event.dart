import '../models/sensor.dart';

abstract class AlarmEvent {
  const AlarmEvent();
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
}

class LoadAlarmPassword extends AlarmEvent {
  const LoadAlarmPassword();
}

class SetAlarmPassword extends AlarmEvent {
  final String password;

  const SetAlarmPassword(this.password);
}
