import 'dart:convert';

import 'package:betty_app/alarm/domain/ports/alarm_port.dart';
import 'package:betty_app/shared/services/api_service.dart';

class AlarmAdapter implements AlarmPort {
  AlarmAdapter({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  @override
  Future<bool> getAlarmStatus() async {
    final response = await _apiService.get('/alarm/status');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['active'] ?? false;
    } else {
      throw Exception('Error al obtener el estado de la alarma');
    }
  }

  @override
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

  @override
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

  @override
  Future<bool> toggleAlarm(bool currentStatus) async {
    if (currentStatus) {
      return await deactivateAlarm();
    } else {
      return await activateAlarm();
    }
  }

  @override
  Future<String> getPassword() async {
    final response = await _apiService.get('/alarm/password');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final password = data['password'];
      if (password is String) {
        return password;
      }
      throw Exception('Error al obtener la contraseña de la alarma');
    } else {
      throw Exception('Error al obtener la contraseña de la alarma');
    }
  }

  @override
  Future<String> setPassword(String password) async {
    final response = await _apiService.post(
      '/alarm/password',
      body: {'password': password},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      final success = data['success'] ?? false;
      if (success) {
        return password;
      } else {
        throw Exception(data['message'] ?? 'Error al actualizar la contraseña');
      }
    } else {
      throw Exception('Error al actualizar la contraseña de la alarma');
    }
  }
}
