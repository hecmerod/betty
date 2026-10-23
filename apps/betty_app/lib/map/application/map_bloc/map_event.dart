import 'package:betty_app/map/domain/entities/map_location.dart';
import 'package:equatable/equatable.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class WatchMapLocations extends MapEvent {
  const WatchMapLocations();
}

class RefreshServerLocation extends MapEvent {
  const RefreshServerLocation();
}

class DeviceLocationUpdated extends MapEvent {
  final MapLocation location;

  const DeviceLocationUpdated(this.location);

  @override
  List<Object?> get props => [location];
}

class DeviceLocationFailed extends MapEvent {
  const DeviceLocationFailed();
}
