import '../models/sensor.dart';

class AlarmState {
  final bool isAlarmActive;
  final bool isLoadingAlarm;
  final bool isTogglingAlarm;
  final List<Sensor> sensors;
  final bool isLoadingSensors;
  final Map<SensorType, bool> togglingSensors;
  final String? errorMessage;

  const AlarmState({
    this.isAlarmActive = false,
    this.isLoadingAlarm = true,
    this.isTogglingAlarm = false,
    this.sensors = const [],
    this.isLoadingSensors = true,
    this.togglingSensors = const {},
    this.errorMessage,
  });

  AlarmState copyWith({
    bool? isAlarmActive,
    bool? isLoadingAlarm,
    bool? isTogglingAlarm,
    List<Sensor>? sensors,
    bool? isLoadingSensors,
    Map<SensorType, bool>? togglingSensors,
    String? errorMessage,
  }) {
    return AlarmState(
      isAlarmActive: isAlarmActive ?? this.isAlarmActive,
      isLoadingAlarm: isLoadingAlarm ?? this.isLoadingAlarm,
      isTogglingAlarm: isTogglingAlarm ?? this.isTogglingAlarm,
      sensors: sensors ?? this.sensors,
      isLoadingSensors: isLoadingSensors ?? this.isLoadingSensors,
      togglingSensors: togglingSensors ?? this.togglingSensors,
      errorMessage: errorMessage,
    );
  }

  bool isSensorToggling(SensorType sensorType) {
    return togglingSensors[sensorType] ?? false;
  }
}
