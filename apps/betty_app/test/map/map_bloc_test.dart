import 'dart:async';

import 'package:betty_app/map/application/map_bloc/map_bloc.dart';
import 'package:betty_app/map/application/map_bloc/map_event.dart';
import 'package:betty_app/map/domain/entities/map_location.dart';
import 'package:betty_app/map/domain/ports/device_location_port.dart';
import 'package:betty_app/map/domain/ports/server_gps_port.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final timestamp = DateTime.utc(2026, 10, 23);

  MapLocation device() =>
      MapLocation(latitude: 40.4168, longitude: -3.7038, timestamp: timestamp);

  MapLocation server() => MapLocation(
    latitude: 41.3874,
    longitude: 2.1686,
    timestamp: timestamp,
    altitude: 12,
  );

  test('loads the device location and the server GPS', () async {
    final bloc = MapBloc(
      deviceLocationPort: _FakeDeviceLocationPort(
        onGetCurrent: () async => device(),
        onWatch: () => const Stream.empty(),
      ),
      serverGpsPort: _FakeServerGpsPort(onGetCurrent: () async => server()),
      serverPollInterval: const Duration(days: 1),
    );
    addTearDown(bloc.close);

    bloc.add(const WatchMapLocations());
    final state = await bloc.stream.firstWhere(
      (value) => value.deviceLocation != null && value.serverLocation != null,
    );

    expect(state.deviceLocation, device());
    expect(state.serverLocation, server());
    expect(state.isLoadingDevice, isFalse);
    expect(state.isLoadingServer, isFalse);
    expect(state.errorMessage, isNull);
  });

  test('keeps updating the device marker from the location stream', () async {
    final updates = StreamController<MapLocation>();
    addTearDown(updates.close);

    final bloc = MapBloc(
      deviceLocationPort: _FakeDeviceLocationPort(
        onGetCurrent: () async => device(),
        onWatch: () => updates.stream,
      ),
      serverGpsPort: _FakeServerGpsPort(onGetCurrent: () async => server()),
      serverPollInterval: const Duration(days: 1),
    );
    addTearDown(bloc.close);

    bloc.add(const WatchMapLocations());
    await bloc.stream.firstWhere((value) => value.deviceLocation != null);

    final moved = MapLocation(
      latitude: 40.42,
      longitude: -3.70,
      timestamp: timestamp,
    );
    updates.add(moved);

    final state = await bloc.stream.firstWhere(
      (value) => value.deviceLocation == moved,
    );
    expect(state.deviceLocation, moved);
    expect(state.serverLocation, server());
  });

  test('reports errors when neither location can be loaded', () async {
    final bloc = MapBloc(
      deviceLocationPort: _FakeDeviceLocationPort(
        onGetCurrent: () async => null,
        onWatch: () => const Stream.empty(),
      ),
      serverGpsPort: _FakeServerGpsPort(
        onGetCurrent: () async => throw Exception('offline'),
      ),
      serverPollInterval: const Duration(days: 1),
    );
    addTearDown(bloc.close);

    bloc.add(const WatchMapLocations());
    final state = await bloc.stream.firstWhere(
      (value) => !value.isLoadingDevice && !value.isLoadingServer,
    );

    expect(state.deviceLocation, isNull);
    expect(state.serverLocation, isNull);
    expect(
      state.deviceErrorMessage,
      'Activa la ubicación para verte en el mapa',
    );
    expect(state.serverErrorMessage, 'Error al obtener el GPS');
    expect(state.errorMessage, 'No se pudieron cargar las ubicaciones');
  });
}

class _FakeDeviceLocationPort implements DeviceLocationPort {
  _FakeDeviceLocationPort({required this.onGetCurrent, required this.onWatch});

  final Future<MapLocation?> Function() onGetCurrent;
  final Stream<MapLocation> Function() onWatch;

  @override
  Future<MapLocation?> getCurrentLocation() => onGetCurrent();

  @override
  Stream<MapLocation> watchLocation() => onWatch();
}

class _FakeServerGpsPort implements ServerGpsPort {
  _FakeServerGpsPort({required this.onGetCurrent});

  final Future<MapLocation> Function() onGetCurrent;

  @override
  Future<MapLocation> getCurrentLocation() => onGetCurrent();
}
