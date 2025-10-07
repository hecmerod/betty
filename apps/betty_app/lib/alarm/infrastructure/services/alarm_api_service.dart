import 'dart:convert';
import '../../../shared/server/betty_api_service.dart';
import '../../../shared/error/error.dart';
import '../../domain/entities/alarm_status.dart';

class AlarmApiService {
  final BettyApiService _apiService;

  const AlarmApiService(this._apiService);

  Future<AlarmStatus> getStatus() async {
    try {
      final response = await _apiService.get('/alarm/status');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return AlarmStatus.fromJson(responseData);
      } else {
        ErrorService().reportNetworkError(
          message: 'Error al obtener el estado de la alarma',
          technicalDetails: 'Server responded with status ${response.statusCode}',
          context: {'endpoint': '/alarm/status', 'statusCode': response.statusCode},
        );
        throw Exception('Error al obtener el estado de la alarma');
      }
    } catch (e, stackTrace) {
      ErrorService().reportNetworkError(
        message: 'Error de conexión al obtener el estado de la alarma',
        technicalDetails: e.toString(),
        context: {'endpoint': '/alarm/status'},
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<AlarmStatus> activate() async {
    try {
      final response = await _apiService.post('/alarm/activate');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Extraer el status de la respuesta y crear AlarmStatus
        return AlarmStatus(
          isActive: responseData['status'] == 'active',
          status: responseData['status'] ?? 'active',
          timestamp: DateTime.now(),
        );
      } else {
        ErrorService().reportNetworkError(
          message: 'Error al activar la alarma',
          technicalDetails: 'Server responded with status ${response.statusCode}',
          context: {'endpoint': '/alarm/activate', 'statusCode': response.statusCode},
        );
        throw Exception('Error al activar la alarma');
      }
    } catch (e, stackTrace) {
      ErrorService().reportNetworkError(
        message: 'Error de conexión al activar la alarma',
        technicalDetails: e.toString(),
        context: {'endpoint': '/alarm/activate'},
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<AlarmStatus> deactivate() async {
    try {
      final response = await _apiService.post('/alarm/deactivate');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Extraer el status de la respuesta y crear AlarmStatus
        return AlarmStatus(
          isActive: responseData['status'] == 'active',
          status: responseData['status'] ?? 'inactive',
          timestamp: DateTime.now(),
        );
      } else {
        ErrorService().reportNetworkError(
          message: 'Error al desactivar la alarma',
          technicalDetails: 'Server responded with status ${response.statusCode}',
          context: {'endpoint': '/alarm/deactivate', 'statusCode': response.statusCode},
        );
        throw Exception('Error al desactivar la alarma');
      }
    } catch (e, stackTrace) {
      ErrorService().reportNetworkError(
        message: 'Error de conexión al desactivar la alarma',
        technicalDetails: e.toString(),
        context: {'endpoint': '/alarm/deactivate'},
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
