import 'dart:async';

import 'package:betty_app/map/application/map_bloc/map_event.dart';
import 'package:betty_app/map/application/map_bloc/map_state.dart';
import 'package:betty_app/map/domain/entities/map_location.dart';
import 'package:betty_app/map/domain/ports/device_location_port.dart';
import 'package:betty_app/map/domain/ports/server_gps_port.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final DeviceLocationPort _deviceLocationPort;
  final ServerGpsPort _serverGpsPort;
  final Duration _serverPollInterval;

  StreamSubscription<MapLocation>? _deviceSubscription;
  Timer? _pollTimer;
  int _watchGeneration = 0;

  MapBloc({
    required DeviceLocationPort deviceLocationPort,
    required ServerGpsPort serverGpsPort,
    Duration serverPollInterval = const Duration(seconds: 15),
  }) : _deviceLocationPort = deviceLocationPort,
       _serverGpsPort = serverGpsPort,
       _serverPollInterval = serverPollInterval,
       super(const MapState()) {
    on<WatchMapLocations>(_onWatchMapLocations);
    on<RefreshServerLocation>(_onRefreshServerLocation);
    on<DeviceLocationUpdated>(_onDeviceLocationUpdated);
    on<DeviceLocationFailed>(_onDeviceLocationFailed);
  }

  Future<void> _onWatchMapLocations(
    WatchMapLocations event,
    Emitter<MapState> emit,
  ) async {
    final generation = ++_watchGeneration;
    final previous = _deviceSubscription;
    _deviceSubscription = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    if (previous != null) unawaited(previous.cancel());
    if (emit.isDone || generation != _watchGeneration) return;

    emit(state.copyWith(isLoadingDevice: true, isLoadingServer: true));

    final results = await Future.wait([
      _readDeviceLocation(),
      _readServerLocation(),
    ]);
    if (emit.isDone || generation != _watchGeneration) return;

    final device = results[0];
    final server = results[1];

    emit(
      state.copyWith(
        deviceLocation: device.location,
        serverLocation: server.location,
        isLoadingDevice: false,
        isLoadingServer: false,
        deviceErrorMessage: device.errorMessage,
        serverErrorMessage: server.errorMessage,
        clearDeviceError: device.errorMessage == null,
        clearServerError: server.errorMessage == null,
      ),
    );

    if (emit.isDone || generation != _watchGeneration) return;

    if (device.location != null) {
      try {
        _deviceSubscription = _deviceLocationPort.watchLocation().listen(
          (location) {
            if (!isClosed && generation == _watchGeneration) {
              add(DeviceLocationUpdated(location));
            }
          },
          onError: (Object _, StackTrace _) {
            if (!isClosed && generation == _watchGeneration) {
              add(const DeviceLocationFailed());
            }
          },
        );
      } catch (_) {
        if (emit.isDone || generation != _watchGeneration) return;
        if (state.deviceErrorMessage != null) return;
        emit(
          state.copyWith(deviceErrorMessage: 'Error al seguir tu ubicación'),
        );
      }
    }

    if (emit.isDone || generation != _watchGeneration) return;
    _pollTimer = Timer.periodic(_serverPollInterval, (_) {
      if (!isClosed && generation == _watchGeneration) {
        add(const RefreshServerLocation());
      }
    });
  }

  Future<void> _onRefreshServerLocation(
    RefreshServerLocation event,
    Emitter<MapState> emit,
  ) async {
    final generation = _watchGeneration;
    final server = await _readServerLocation();
    if (emit.isDone || generation != _watchGeneration) return;

    if (server.location == null && state.serverLocation != null) return;

    emit(
      state.copyWith(
        serverLocation: server.location,
        isLoadingServer: false,
        serverErrorMessage: server.errorMessage,
        clearServerError: server.errorMessage == null,
      ),
    );
  }

  void _onDeviceLocationUpdated(
    DeviceLocationUpdated event,
    Emitter<MapState> emit,
  ) {
    emit(
      state.copyWith(
        deviceLocation: event.location,
        isLoadingDevice: false,
        clearDeviceError: true,
      ),
    );
  }

  void _onDeviceLocationFailed(
    DeviceLocationFailed event,
    Emitter<MapState> emit,
  ) {
    emit(
      state.copyWith(
        isLoadingDevice: false,
        deviceErrorMessage: 'Error al seguir tu ubicación',
      ),
    );
  }

  Future<_LocationResult> _readDeviceLocation() async {
    try {
      final location = await _deviceLocationPort.getCurrentLocation();
      if (location == null) {
        return const _LocationResult(
          errorMessage: 'Activa la ubicación para verte en el mapa',
        );
      }
      return _LocationResult(location: location);
    } catch (_) {
      return const _LocationResult(
        errorMessage: 'Error al obtener tu ubicación',
      );
    }
  }

  Future<_LocationResult> _readServerLocation() async {
    try {
      return _LocationResult(
        location: await _serverGpsPort.getCurrentLocation(),
      );
    } catch (_) {
      return const _LocationResult(errorMessage: 'Error al obtener el GPS');
    }
  }

  @override
  Future<void> close() {
    _watchGeneration++;
    _pollTimer?.cancel();
    _deviceSubscription?.cancel();
    return super.close();
  }
}

class _LocationResult {
  final MapLocation? location;
  final String? errorMessage;

  const _LocationResult({this.location, this.errorMessage});
}
