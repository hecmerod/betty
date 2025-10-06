import '../entities/gps_location.dart';
import '../repositories/i_gps_repository.dart';

class GetCurrentLocationUseCase {
  final IGpsRepository _gpsRepository;

  GetCurrentLocationUseCase(this._gpsRepository);

  Future<GpsLocation> execute() async {
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

    // Obtener la ubicación actual
    return await _gpsRepository.getCurrentLocation();
  }
}
