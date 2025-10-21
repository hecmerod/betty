import 'package:flutter/material.dart';
import '../../domain/entities/alarm_status.dart';
import '../../application/use_cases/get_alarm_status_use_case.dart';
import '../../application/use_cases/toggle_alarm_use_case.dart';

class AlarmProvider with ChangeNotifier {
  final GetAlarmStatusUseCase _getAlarmStatusUseCase;
  final ToggleAlarmUseCase _toggleAlarmUseCase;

  AlarmProvider(this._getAlarmStatusUseCase, this._toggleAlarmUseCase);

  AlarmStatus? _alarmStatus;
  bool _isLoading = false;
  String? _errorMessage;

  AlarmStatus? get alarmStatus => _alarmStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAlarmStatus() async {
    _setLoading(true);
    _clearError();

    try {
      final status = await _getAlarmStatusUseCase.execute();
      _alarmStatus = status;
    } catch (e) {
      _setError('Error al cargar el estado de la alarma: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleAlarm() async {
    if (_alarmStatus == null) return;

    _setLoading(true);
    _clearError();

    try {
      final newStatus = await _toggleAlarmUseCase.execute(!_alarmStatus!.isActive);
      _alarmStatus = newStatus;
    } catch (e) {
      _setError('Error al cambiar el estado de la alarma: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
