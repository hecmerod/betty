import 'dart:convert';
import '../../shared/services/api_service.dart';

class AlarmService {
  static final AlarmService instance = AlarmService._();
  AlarmService._();

  final _apiService = ApiService.instance;

  /// Obtiene el estado actual de la alarma
  Future<bool> getAlarmStatus() async {
    try {
      final response = await _apiService.get('/alarm/status');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // El servidor devuelve 'active' en vez de 'isActive'
        return data['active'] ?? false;
      } else {
        throw Exception('Error al obtener el estado de la alarma');
      }
    } catch (e) {
      print('Error en getAlarmStatus: $e');
      rethrow;
    }
  }

  /// Activa la alarma
  Future<bool> activateAlarm() async {
    try {
      final response = await _apiService.post('/alarm/activate');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        // Verificamos si la activación fue exitosa
        final success = data['success'] ?? false;
        if (success) {
          return true;
        } else {
          throw Exception(data['message'] ?? 'Error al activar la alarma');
        }
      } else {
        throw Exception('Error al activar la alarma');
      }
    } catch (e) {
      print('Error en activateAlarm: $e');
      rethrow;
    }
  }

  /// Desactiva la alarma
  Future<bool> deactivateAlarm() async {
    try {
      final response = await _apiService.post('/alarm/deactivate');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        // Verificamos si la desactivación fue exitosa
        final success = data['success'] ?? false;
        if (success) {
          return false;
        } else {
          throw Exception(data['message'] ?? 'Error al desactivar la alarma');
        }
      } else {
        throw Exception('Error al desactivar la alarma');
      }
    } catch (e) {
      print('Error en deactivateAlarm: $e');
      rethrow;
    }
  }

  /// Cambia el estado de la alarma (activa/desactiva)
  Future<bool> toggleAlarm(bool currentStatus) async {
    if (currentStatus) {
      return await deactivateAlarm();
    } else {
      return await activateAlarm();
    }
  }
}
