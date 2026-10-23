import 'package:betty_app/map/domain/entities/map_location.dart';
import 'package:equatable/equatable.dart';

class MapState extends Equatable {
  final MapLocation? deviceLocation;
  final MapLocation? serverLocation;
  final bool isLoadingDevice;
  final bool isLoadingServer;
  final String? deviceErrorMessage;
  final String? serverErrorMessage;

  const MapState({
    this.deviceLocation,
    this.serverLocation,
    this.isLoadingDevice = true,
    this.isLoadingServer = true,
    this.deviceErrorMessage,
    this.serverErrorMessage,
  });

  MapState copyWith({
    MapLocation? deviceLocation,
    MapLocation? serverLocation,
    bool? isLoadingDevice,
    bool? isLoadingServer,
    String? deviceErrorMessage,
    String? serverErrorMessage,
    bool clearDeviceError = false,
    bool clearServerError = false,
  }) {
    return MapState(
      deviceLocation: deviceLocation ?? this.deviceLocation,
      serverLocation: serverLocation ?? this.serverLocation,
      isLoadingDevice: isLoadingDevice ?? this.isLoadingDevice,
      isLoadingServer: isLoadingServer ?? this.isLoadingServer,
      deviceErrorMessage: clearDeviceError
          ? null
          : (deviceErrorMessage ?? this.deviceErrorMessage),
      serverErrorMessage: clearServerError
          ? null
          : (serverErrorMessage ?? this.serverErrorMessage),
    );
  }

  String? get errorMessage {
    if (deviceErrorMessage != null && serverErrorMessage != null) {
      return 'No se pudieron cargar las ubicaciones';
    }
    return deviceErrorMessage ?? serverErrorMessage;
  }

  @override
  List<Object?> get props => [
    deviceLocation,
    serverLocation,
    isLoadingDevice,
    isLoadingServer,
    deviceErrorMessage,
    serverErrorMessage,
  ];
}
