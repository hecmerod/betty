import '../entities/map_location.dart';
import '../repositories/i_map_repository.dart';

class GetVehicleLocationUseCase {
  final IMapRepository _mapRepository;

  GetVehicleLocationUseCase(this._mapRepository);

  Future<MapLocation> execute() async {
    // Obtener la ubicación del vehículo desde el servidor
    return await _mapRepository.getVehicleLocation();
  }
}
