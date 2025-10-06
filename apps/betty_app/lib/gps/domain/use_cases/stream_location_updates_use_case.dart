import '../entities/gps_location.dart';
import '../repositories/i_gps_repository.dart';

class StreamLocationUpdatesUseCase {
  final IGpsRepository _gpsRepository;

  StreamLocationUpdatesUseCase(this._gpsRepository);

  Stream<GpsLocation> execute() async* {
    // Verificar si los servicios de ubicación están habilitados
    final isServiceEnabled = await _gpsRepository.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw Exception('Los servicios de ubicación están deshabilitados');
    }

    // Verificar y solicitar permisos si es necesario
    final hasPermission = await _gpsRepository.hasLocationPermission();
    if (!hasPermission) {
      final permissionGranted = await _gpsRepository.requestLocationPermission();
      if (!permissionGranted) {
        throw Exception('Permisos de ubicación denegados');
      }
    }

    // Retornar el stream de ubicaciones
    yield* _gpsRepository.getLocationStream();
  }
}
