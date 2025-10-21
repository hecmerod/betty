import '../entities/map_location.dart';
import '../repositories/i_map_repository.dart';

class GetCurrentLocationUseCase {
  final IMapRepository _mapRepository;

  GetCurrentLocationUseCase(this._mapRepository);

  Future<MapLocation> execute() async {
    // Verificar si los servicios de ubicación están habilitados
    final isServiceEnabled = await _mapRepository.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw Exception('Los servicios de ubicación están deshabilitados');
    }

    // Verificar y solicitar permisos si es necesario
    final hasPermission = await _mapRepository.hasLocationPermission();
    if (!hasPermission) {
      final permissionGranted = await _mapRepository.requestLocationPermission();
      if (!permissionGranted) {
        throw Exception('Permisos de ubicación denegados');
      }
    }

    // Obtener la ubicación actual
    return await _mapRepository.getCurrentLocation();
  }
}
