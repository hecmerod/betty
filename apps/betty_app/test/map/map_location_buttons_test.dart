import 'package:betty_app/map/application/map_bloc/map_bloc.dart';
import 'package:betty_app/map/application/map_bloc/map_event.dart';
import 'package:betty_app/map/domain/entities/map_location.dart';
import 'package:betty_app/map/domain/ports/device_location_port.dart';
import 'package:betty_app/map/domain/ports/server_gps_port.dart';
import 'package:betty_app/map/presentation/widgets/map_error_banner.dart';
import 'package:betty_app/map/presentation/widgets/map_location_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final timestamp = DateTime.utc(2026, 10, 23);
  final device = MapLocation(
    latitude: 40.4168,
    longitude: -3.7038,
    timestamp: timestamp,
  );
  final server = MapLocation(
    latitude: 41.3874,
    longitude: 2.1686,
    timestamp: timestamp,
  );

  testWidgets('shows both jump buttons and reports taps', (tester) async {
    var deviceTaps = 0;
    var serverTaps = 0;

    await tester.pumpWidget(
      _app(
        devicePort: _FakeDeviceLocationPort(
          onGetCurrent: () async => device,
          onWatch: () => const Stream.empty(),
        ),
        serverPort: _FakeServerGpsPort(onGetCurrent: () async => server),
        child: MapLocationButtons(
          onGoToDevice: () => deviceTaps++,
          onGoToServer: () => serverTaps++,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byTooltip('Ir a Betty'), findsOneWidget);
    expect(find.byTooltip('Ir a tu ubicación'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('map-server-location-button')));
    await tester.tap(find.byKey(const ValueKey('map-device-location-button')));

    expect(serverTaps, 1);
    expect(deviceTaps, 1);
  });

  testWidgets('shows a retry action when locations cannot be loaded', (
    tester,
  ) async {
    var serverCalls = 0;
    final serverPort = _FakeServerGpsPort(
      onGetCurrent: () async {
        serverCalls++;
        throw Exception('offline');
      },
    );

    await tester.pumpWidget(
      _app(
        devicePort: _FakeDeviceLocationPort(
          onGetCurrent: () async => null,
          onWatch: () => const Stream.empty(),
        ),
        serverPort: serverPort,
        child: const MapErrorBanner(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('No se pudieron cargar las ubicaciones'), findsOneWidget);
    expect(serverCalls, 1);

    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    await tester.pump();

    expect(serverCalls, 2);
  });
}

Widget _app({
  required DeviceLocationPort devicePort,
  required ServerGpsPort serverPort,
  required Widget child,
}) {
  return MaterialApp(
    home: BlocProvider(
      create: (_) => MapBloc(
        deviceLocationPort: devicePort,
        serverGpsPort: serverPort,
        serverPollInterval: const Duration(days: 1),
      )..add(const WatchMapLocations()),
      child: Scaffold(body: child),
    ),
  );
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
