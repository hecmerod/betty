import 'package:geolocator/geolocator.dart';
import '../../domain/entities/map_location.dart';
import '../../domain/entities/map_type.dart';
import '../../domain/repositories/i_map_repository.dart';

class MapRepositoryImpl implements IMapRepository {
  MapType _currentMapType = MapType.standard;

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
