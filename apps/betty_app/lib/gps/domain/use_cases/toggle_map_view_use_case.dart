import '../entities/map_type.dart';
import '../repositories/i_gps_repository.dart';

class ToggleMapViewUseCase {
  final IGpsRepository _gpsRepository;

  ToggleMapViewUseCase(this._gpsRepository);

  void execute() {
    final currentMapType = _gpsRepository.getMapType();
    final newMapType = currentMapType == MapType.standard ? MapType.satellite : MapType.standard;

    _gpsRepository.setMapType(newMapType);
  }

  MapType getCurrentMapType() {
    return _gpsRepository.getMapType();
  }
}
