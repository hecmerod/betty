import 'package:betty_app/alarm/domain/entities/alarm.dart';
import 'package:betty_app/alarm/domain/entities/sensor.dart';
import 'package:equatable/equatable.dart';

class AlarmState extends Equatable {
  final Alarm alarm;
  final bool isLoadingAlarm;
  final bool isTogglingAlarm;
  final List<Sensor> sensors;
  final bool isLoadingSensors;
  final bool isLoadingPassword;
  final bool isSavingPassword;
  final String? errorMessage;
  final String? successMessage;

  const AlarmState({
    this.alarm = const Alarm(),
    this.isLoadingAlarm = true,
    this.isTogglingAlarm = false,
    this.sensors = const [],
    this.isLoadingSensors = true,
    this.isLoadingPassword = true,
    this.isSavingPassword = false,
    this.errorMessage,
    this.successMessage,
  });

  AlarmState copyWith({
    Alarm? alarm,
    bool? isLoadingAlarm,
    bool? isTogglingAlarm,
    List<Sensor>? sensors,
    bool? isLoadingSensors,
    bool? isLoadingPassword,
    bool? isSavingPassword,
    String? errorMessage,
    String? successMessage,
  }) {
    return AlarmState(
      alarm: alarm ?? this.alarm,
      isLoadingAlarm: isLoadingAlarm ?? this.isLoadingAlarm,
      isTogglingAlarm: isTogglingAlarm ?? this.isTogglingAlarm,
      sensors: sensors ?? this.sensors,
      isLoadingSensors: isLoadingSensors ?? this.isLoadingSensors,
      isLoadingPassword: isLoadingPassword ?? this.isLoadingPassword,
      isSavingPassword: isSavingPassword ?? this.isSavingPassword,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    alarm,
    isLoadingAlarm,
    isTogglingAlarm,
    sensors,
    isLoadingSensors,
    isLoadingPassword,
    isSavingPassword,
    errorMessage,
    successMessage,
  ];
}
