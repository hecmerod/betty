import 'dart:convert';
import '../../../shared/server/betty_api_service.dart';
import '../../../shared/error/services/error_service.dart';
import '../../domain/entities/trip.dart';

class TripApiService {
  final BettyApiService _apiService;

  const TripApiService(this._apiService);

  Future<List<Trip>> getAllTrips() async {
    try {
      final response = await _apiService.get('/trips');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((json) => Trip.fromJson(json)).toList();
      } else {
        ErrorService().reportNetworkError(
          message: 'Error al obtener los viajes',
          technicalDetails: 'Server responded with status ${response.statusCode}',
          context: {'endpoint': '/trips', 'statusCode': response.statusCode},
        );
        throw Exception('Error al obtener los viajes');
      }
    } catch (e, stackTrace) {
      ErrorService().reportNetworkError(
        message: 'Error de conexión al obtener los viajes',
        technicalDetails: e.toString(),
        context: {'endpoint': '/trips'},
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Trip?> getCurrentTrip() async {
    try {
      final response = await _apiService.get('/trips/current');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Trip.fromJson(responseData);
      } else if (response.statusCode == 404) {
        // No hay trip en progreso
        return null;
      } else {
        ErrorService().reportNetworkError(
          message: 'Error al obtener el viaje actual',
          technicalDetails: 'Server responded with status ${response.statusCode}',
          context: {'endpoint': '/trips/current', 'statusCode': response.statusCode},
        );
        throw Exception('Error al obtener el viaje actual');
      }
    } catch (e, stackTrace) {
      ErrorService().reportNetworkError(
        message: 'Error de conexión al obtener el viaje actual',
        technicalDetails: e.toString(),
        context: {'endpoint': '/trips/current'},
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<bool> hasTripInProgress() async {
    try {
      final response = await _apiService.get('/trips/in-progress');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // El servidor devuelve { hasInProgress: boolean }
        return responseData['hasInProgress'] as bool;
      } else {
        ErrorService().reportNetworkError(
          message: 'Error al verificar si hay viaje en progreso',
          technicalDetails: 'Server responded with status ${response.statusCode}',
          context: {'endpoint': '/trips/in-progress', 'statusCode': response.statusCode},
        );
        throw Exception('Error al verificar si hay viaje en progreso');
      }
    } catch (e, stackTrace) {
      ErrorService().reportNetworkError(
        message: 'Error de conexión al verificar si hay viaje en progreso',
        technicalDetails: e.toString(),
        context: {'endpoint': '/trips/in-progress'},
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Trip?> getTripById(String id) async {
    try {
      final response = await _apiService.get('/trips/$id');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Trip.fromJson(responseData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        ErrorService().reportNetworkError(
          message: 'Error al obtener el viaje',
          technicalDetails: 'Server responded with status ${response.statusCode}',
          context: {'endpoint': '/trips/$id', 'statusCode': response.statusCode},
        );
        throw Exception('Error al obtener el viaje');
      }
    } catch (e, stackTrace) {
      ErrorService().reportNetworkError(
        message: 'Error de conexión al obtener el viaje',
        technicalDetails: e.toString(),
        context: {'endpoint': '/trips/$id'},
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Trip> createTrip(String name) async {
    try {
      final response = await _apiService.post('/trips', body: {'name': name});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Trip.fromJson(responseData);
      } else if (response.statusCode == 409) {
        throw Exception('Ya hay un viaje en progreso');
      } else {
        ErrorService().reportNetworkError(
          message: 'Error al crear el viaje',
          technicalDetails: 'Server responded with status ${response.statusCode}',
          context: {'endpoint': '/trips', 'statusCode': response.statusCode},
        );
        throw Exception('Error al crear el viaje');
      }
    } catch (e, stackTrace) {
      if (e.toString().contains('Ya hay un viaje en progreso')) {
        rethrow;
      }
      ErrorService().reportNetworkError(
        message: 'Error de conexión al crear el viaje',
        technicalDetails: e.toString(),
        context: {'endpoint': '/trips'},
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Trip> endTrip(String id) async {
    try {
      final response = await _apiService.post('/trips/$id/end');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Trip.fromJson(responseData);
      } else if (response.statusCode == 404) {
        throw Exception('Viaje no encontrado');
      } else if (response.statusCode == 409) {
        throw Exception('El viaje ya ha finalizado');
      } else {
        ErrorService().reportNetworkError(
          message: 'Error al finalizar el viaje',
          technicalDetails: 'Server responded with status ${response.statusCode}',
          context: {'endpoint': '/trips/$id/end', 'statusCode': response.statusCode},
        );
        throw Exception('Error al finalizar el viaje');
      }
    } catch (e, stackTrace) {
      if (e.toString().contains('Viaje no encontrado') || e.toString().contains('El viaje ya ha finalizado')) {
        rethrow;
      }
      ErrorService().reportNetworkError(
        message: 'Error de conexión al finalizar el viaje',
        technicalDetails: e.toString(),
        context: {'endpoint': '/trips/$id/end'},
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
