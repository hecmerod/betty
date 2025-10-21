import '../entities/map_type.dart';
import '../repositories/i_map_repository.dart';

class ToggleMapViewUseCase {
  final IMapRepository _mapRepository;

  ToggleMapViewUseCase(this._mapRepository);

  void execute() {
    final currentMapType = _mapRepository.getMapType();
    final newMapType = currentMapType == MapType.standard ? MapType.satellite : MapType.standard;

    _mapRepository.setMapType(newMapType);
  }

  MapType getCurrentMapType() {
    return _mapRepository.getMapType();
  }
}
