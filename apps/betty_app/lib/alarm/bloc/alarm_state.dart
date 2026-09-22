import '../models/sensor.dart';

class AlarmState {
  final bool isAlarmActive;
  final bool isLoadingAlarm;
  final bool isTogglingAlarm;
  final List<Sensor> sensors;
  final bool isLoadingSensors;
  final Map<SensorType, bool> togglingSensors;
  final String? password;
  final bool isLoadingPassword;
  final bool isSavingPassword;
  final String? errorMessage;
  final String? successMessage;

  const AlarmState({
    this.isAlarmActive = false,
    this.isLoadingAlarm = true,
    this.isTogglingAlarm = false,
    this.sensors = const [],
    this.isLoadingSensors = true,
    this.togglingSensors = const {},
    this.password,
    this.isLoadingPassword = true,
    this.isSavingPassword = false,
    this.errorMessage,
    this.successMessage,
  });

  AlarmState copyWith({
    bool? isAlarmActive,
    bool? isLoadingAlarm,
    bool? isTogglingAlarm,
    List<Sensor>? sensors,
    bool? isLoadingSensors,
    Map<SensorType, bool>? togglingSensors,
    String? password,
    bool? isLoadingPassword,
    bool? isSavingPassword,
    String? errorMessage,
    String? successMessage,
  }) {
    return AlarmState(
      isAlarmActive: isAlarmActive ?? this.isAlarmActive,
      isLoadingAlarm: isLoadingAlarm ?? this.isLoadingAlarm,
      isTogglingAlarm: isTogglingAlarm ?? this.isTogglingAlarm,
      sensors: sensors ?? this.sensors,
      isLoadingSensors: isLoadingSensors ?? this.isLoadingSensors,
      togglingSensors: togglingSensors ?? this.togglingSensors,
      password: password ?? this.password,
      isLoadingPassword: isLoadingPassword ?? this.isLoadingPassword,
      isSavingPassword: isSavingPassword ?? this.isSavingPassword,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  bool isSensorToggling(SensorType sensorType) {
    return togglingSensors[sensorType] ?? false;
  }
}
