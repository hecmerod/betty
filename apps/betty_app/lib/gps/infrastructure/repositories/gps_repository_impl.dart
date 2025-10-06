import 'package:geolocator/geolocator.dart';
import '../../domain/entities/gps_location.dart';
import '../../domain/entities/map_type.dart';
import '../../domain/repositories/i_gps_repository.dart';

class GpsRepositoryImpl implements IGpsRepository {
  MapType _currentMapType = MapType.standard;

  @override
  Future<GpsLocation> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    );

    return GpsLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }

  @override
  Stream<GpsLocation> getLocationStream() {
    const locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);

    return Geolocator.getPositionStream(locationSettings: locationSettings).map(
      (position) => GpsLocation(
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
