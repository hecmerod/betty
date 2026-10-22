import 'package:betty_app/alarm/application/alarm_bloc/alarm_event.dart';
import 'package:betty_app/alarm/application/alarm_bloc/alarm_state.dart';
import 'package:betty_app/alarm/domain/ports/alarm_port.dart';
import 'package:betty_app/alarm/domain/ports/sensor_port.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final AlarmPort _alarmPort;
  final SensorPort _sensorPort;

  AlarmBloc({required AlarmPort alarmPort, required SensorPort sensorPort})
    : _alarmPort = alarmPort,
      _sensorPort = sensorPort,
      super(const AlarmState()) {
    on<LoadAlarmStatus>(_onLoadAlarmStatus);
    on<ToggleAlarm>(_onToggleAlarm);
    on<LoadSensors>(_onLoadSensors);
    on<ToggleSensor>(_onToggleSensor);
    on<LoadAlarmPassword>(_onLoadAlarmPassword);
    on<SetAlarmPassword>(_onSetAlarmPassword);
  }

  Future<void> _onLoadAlarmStatus(
    LoadAlarmStatus event,
    Emitter<AlarmState> emit,
  ) async {
    emit(state.copyWith(isLoadingAlarm: true));

    try {
      final isActive = await _alarmPort.getAlarmStatus();
      emit(
        state.copyWith(
          alarm: state.alarm.copyWith(isActive: isActive),
          isLoadingAlarm: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingAlarm: false,
          errorMessage: 'Error al cargar el estado de la alarma',
        ),
      );
    }
  }

  Future<void> _onToggleAlarm(
    ToggleAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    emit(state.copyWith(isTogglingAlarm: true));

    try {
      final isActive = await _alarmPort.toggleAlarm(state.alarm.isActive);
      emit(
        state.copyWith(
          alarm: state.alarm.copyWith(isActive: isActive),
          isTogglingAlarm: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isTogglingAlarm: false,
          errorMessage: 'Error al cambiar el estado de la alarma',
        ),
      );
    }
  }

  Future<void> _onLoadSensors(
    LoadSensors event,
    Emitter<AlarmState> emit,
  ) async {
    emit(state.copyWith(isLoadingSensors: true));

    try {
      final sensors = await _sensorPort.getSensorsStatus();
      emit(state.copyWith(sensors: sensors, isLoadingSensors: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingSensors: false,
          errorMessage: 'Error al cargar los sensores',
        ),
      );
    }
  }

  Future<void> _onToggleSensor(
    ToggleSensor event,
    Emitter<AlarmState> emit,
  ) async {
    if (!state.alarm.isActive) return;

    final index = state.sensors.indexWhere(
      (item) => item.type == event.sensorType,
    );
    if (index == -1) return;
    final sensor = state.sensors[index];

    final updatedSensors = state.sensors.map((item) {
      if (item.type == event.sensorType) {
        return item.copyWith(isListening: !item.isListening);
      }
      return item;
    }).toList();

    emit(state.copyWith(sensors: updatedSensors));

    try {
      await _sensorPort.toggleSensor(event.sensorType, sensor.isListening);
    } catch (e) {
      final revertedSensors = state.sensors.map((item) {
        if (item.type == event.sensorType) {
          return item.copyWith(isListening: !item.isListening);
        }
        return item;
      }).toList();

      emit(
        state.copyWith(
          sensors: revertedSensors,
          errorMessage: 'Error al cambiar el estado del sensor',
        ),
      );
    }
  }

  Future<void> _onLoadAlarmPassword(
    LoadAlarmPassword event,
    Emitter<AlarmState> emit,
  ) async {
    emit(state.copyWith(isLoadingPassword: true));

    try {
      final password = await _alarmPort.getPassword();
      emit(
        state.copyWith(
          alarm: state.alarm.copyWith(password: password),
          isLoadingPassword: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingPassword: false,
          errorMessage: 'Error al cargar la contraseña',
        ),
      );
    }
  }

  Future<void> _onSetAlarmPassword(
    SetAlarmPassword event,
    Emitter<AlarmState> emit,
  ) async {
    if (!RegExp(r'^\d{4}$').hasMatch(event.password)) {
      emit(state.copyWith(errorMessage: 'La contraseña debe tener 4 dígitos'));
      return;
    }

    emit(state.copyWith(isSavingPassword: true));

    try {
      final password = await _alarmPort.setPassword(event.password);
      emit(
        state.copyWith(
          alarm: state.alarm.copyWith(password: password),
          isSavingPassword: false,
          successMessage: 'Contraseña actualizada',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSavingPassword: false,
          errorMessage: 'Error al actualizar la contraseña',
        ),
      );
    }
  }
}
