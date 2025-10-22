import 'dart:convert';
import '../../shared/services/api_service.dart';

class AlarmService {
  static final AlarmService instance = AlarmService._();
  AlarmService._();

  final _apiService = ApiService.instance;

  Future<bool> getAlarmStatus() async {
    final response = await _apiService.get('/alarm/status');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['active'] ?? false;
    } else {
      throw Exception('Error al obtener el estado de la alarma');
    }
  }

  Future<bool> activateAlarm() async {
    final response = await _apiService.post('/alarm/activate');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      final success = data['success'] ?? false;
      if (success) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'Error al activar la alarma');
      }
    } else {
      throw Exception('Error al activar la alarma');
    }
  }

  Future<bool> deactivateAlarm() async {
    final response = await _apiService.post('/alarm/deactivate');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      final success = data['success'] ?? false;
      if (success) {
        return false;
      } else {
        throw Exception(data['message'] ?? 'Error al desactivar la alarma');
      }
    } else {
      throw Exception('Error al desactivar la alarma');
    }
  }

  Future<bool> toggleAlarm(bool currentStatus) async {
    if (currentStatus) {
      return await deactivateAlarm();
    } else {
      return await activateAlarm();
    }
  }
}
