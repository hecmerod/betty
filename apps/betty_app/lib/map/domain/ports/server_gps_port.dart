import 'package:betty_app/map/domain/entities/map_location.dart';

abstract class ServerGpsPort {
  Future<MapLocation> getCurrentLocation();
}
