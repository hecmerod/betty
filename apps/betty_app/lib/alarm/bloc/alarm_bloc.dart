import 'package:flutter_bloc/flutter_bloc.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';
import '../services/alarm_service.dart';
import '../services/sensor_service.dart';
import '../models/sensor.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final AlarmService _alarmService = AlarmService.instance;
  final SensorService _sensorService = SensorService.instance;

  AlarmBloc() : super(const AlarmState()) {
    on<LoadAlarmStatus>(_onLoadAlarmStatus);
    on<ToggleAlarm>(_onToggleAlarm);
    on<LoadSensors>(_onLoadSensors);
    on<ToggleSensor>(_onToggleSensor);
  }

  Future<void> _onLoadAlarmStatus(LoadAlarmStatus event, Emitter<AlarmState> emit) async {
    emit(state.copyWith(isLoadingAlarm: true, errorMessage: null));

    try {
      final isActive = await _alarmService.getAlarmStatus();
      emit(state.copyWith(isAlarmActive: isActive, isLoadingAlarm: false));
    } catch (e) {
      emit(state.copyWith(isLoadingAlarm: false, errorMessage: 'Error al cargar el estado de la alarma'));
    }
  }

  Future<void> _onToggleAlarm(ToggleAlarm event, Emitter<AlarmState> emit) async {
    emit(state.copyWith(isTogglingAlarm: true, errorMessage: null));

    try {
      final newStatus = await _alarmService.toggleAlarm(state.isAlarmActive);
      emit(state.copyWith(isAlarmActive: newStatus, isTogglingAlarm: false));
    } catch (e) {
      emit(state.copyWith(isTogglingAlarm: false, errorMessage: 'Error al cambiar el estado de la alarma'));
    }
  }

  Future<void> _onLoadSensors(LoadSensors event, Emitter<AlarmState> emit) async {
    emit(state.copyWith(isLoadingSensors: true, errorMessage: null));

    try {
      final sensors = await _sensorService.getSensorsStatus();
      emit(state.copyWith(sensors: sensors, isLoadingSensors: false));
    } catch (e) {
      emit(state.copyWith(isLoadingSensors: false, errorMessage: 'Error al cargar los sensores'));
    }
  }

  Future<void> _onToggleSensor(ToggleSensor event, Emitter<AlarmState> emit) async {
    try {
      final sensor = state.sensors.firstWhere(
        (s) => s.type == event.sensorType,
        orElse: () => Sensor(type: event.sensorType, isListening: false),
      );

      final updatedSensors = state.sensors.map((s) {
        if (s.type == event.sensorType) {
          return s.copyWith(isListening: !s.isListening);
        }
        return s;
      }).toList();

      emit(state.copyWith(sensors: updatedSensors, errorMessage: null));

      await _sensorService.toggleSensor(event.sensorType, sensor.isListening);
    } catch (e) {
      final revertedSensors = state.sensors.map((s) {
        if (s.type == event.sensorType) {
          return s.copyWith(isListening: !s.isListening);
        }
        return s;
      }).toList();

      emit(state.copyWith(sensors: revertedSensors, errorMessage: 'Error al cambiar el estado del sensor'));
    }
  }
}
