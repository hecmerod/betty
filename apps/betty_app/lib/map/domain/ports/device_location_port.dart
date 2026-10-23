import 'package:betty_app/map/domain/entities/map_location.dart';

abstract class DeviceLocationPort {
  Future<MapLocation?> getCurrentLocation();

  Stream<MapLocation> watchLocation();
}
