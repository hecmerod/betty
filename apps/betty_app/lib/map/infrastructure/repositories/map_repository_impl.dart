import 'package:geolocator/geolocator.dart';
import '../../domain/entities/map_location.dart';
import '../../domain/entities/map_type.dart';
import '../../domain/repositories/i_map_repository.dart';
import '../adapters/map_api_adapter.dart';

class MapRepositoryImpl implements IMapRepository {
  final MapApiAdapter _apiAdapter;
  MapType _currentMapType = MapType.satellite;

  MapRepositoryImpl({required MapApiAdapter apiAdapter}) : _apiAdapter = apiAdapter;

  @override
  Future<MapLocation> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    );

    return MapLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }

  @override
  Stream<MapLocation> getLocationStream() {
    const locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);

    return Geolocator.getPositionStream(locationSettings: locationSettings).map(
      (position) => MapLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      ),
    );
  }

  @override
  Future<MapLocation> getVehicleLocation() {
    return _apiAdapter.getVehicleLocation();
  }

  @override
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  void setMapType(MapType mapType) {
    _currentMapType = mapType;
  }

  @override
  MapType getMapType() {
    return _currentMapType;
  }
}
