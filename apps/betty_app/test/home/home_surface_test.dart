import 'dart:async';

import 'package:betty_app/batteries/domain/entities/battery_reading.dart';
import 'package:betty_app/batteries/domain/ports/batteries_port.dart';
import 'package:betty_app/home/application/home_batteries_bloc/home_batteries_bloc.dart';
import 'package:betty_app/home/application/home_batteries_bloc/home_batteries_event.dart';
import 'package:betty_app/home/application/home_surface_bloc/home_surface_bloc.dart';
import 'package:betty_app/home/presentation/widgets/app_bar/app_bar.dart';
import 'package:betty_app/home/presentation/widgets/home_surface_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(envString: 'APP_LOGO=assets/betty-icon.png');
  });

  testWidgets(
    'battery button replaces the dashboard and the logo brings it back',
    (tester) async {
      final port = _FakeBatteriesPort(
        onReadAll: () async => [_reading(remainingCapacity: 60)],
      );

      await tester.pumpWidget(
        RepositoryProvider<BatteriesPort>.value(
          value: port,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => HomeSurfaceBloc()),
              BlocProvider(
                create: (context) => HomeBatteriesBloc(
                  batteriesPort: context.read<BatteriesPort>(),
                )..add(const LoadHomeBatteries()),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(appBar: CustomAppBar(), body: HomeSurfaceBody()),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Luces'), findsOneWidget);
      expect(find.text('Batería 1'), findsNothing);

      await tester.tap(find.text('60%'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Batería 1'), findsOneWidget);
      expect(find.text('Luces'), findsNothing);

      await tester.tap(find.byKey(const Key('homeLogo')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Luces'), findsOneWidget);
      expect(find.text('Batería 1'), findsNothing);
    },
  );

  testWidgets('keeps the batteries stream open when leaving and returning', (
    tester,
  ) async {
    var reads = 0;
    var streams = 0;
    final updates = StreamController<BatteryReading>();
    addTearDown(updates.close);

    final port = _FakeBatteriesPort(
      onReadAll: () async {
        reads++;
        return [_reading(remainingCapacity: 60)];
      },
      onStreamAll: () {
        streams++;
        return updates.stream;
      },
    );

    await tester.pumpWidget(
      RepositoryProvider<BatteriesPort>.value(
        value: port,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => HomeSurfaceBloc()),
            BlocProvider(
              create: (context) => HomeBatteriesBloc(
                batteriesPort: context.read<BatteriesPort>(),
              )..add(const LoadHomeBatteries()),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(appBar: CustomAppBar(), body: HomeSurfaceBody()),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(reads, 1);
    expect(streams, 0);

    await tester.tap(find.text('60%'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Batería 1'), findsOneWidget);
    expect(reads, 2);
    expect(streams, 1);

    await tester.tap(find.byKey(const Key('homeLogo')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    updates.add(_reading(remainingCapacity: 40));
    await tester.pump();

    await tester.tap(find.text('60%'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Batería 1'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(reads, 2);
    expect(streams, 1);

    await tester.pumpWidget(const SizedBox());
  });
}

class _FakeBatteriesPort implements BatteriesPort {
  _FakeBatteriesPort({required this.onReadAll, this.onStreamAll});

  final Future<List<BatteryReading>> Function() onReadAll;
  final Stream<BatteryReading> Function()? onStreamAll;

  @override
  Future<List<BatteryReading>> readAllBatteries() => onReadAll();

  @override
  Stream<BatteryReading> streamAllBatteries() =>
      onStreamAll?.call() ?? const Stream.empty();

  @override
  Future<BatteryReading> readBattery(int batteryId) {
    throw UnimplementedError();
  }

  @override
  Stream<BatteryReading> streamBattery(int batteryId) => const Stream.empty();
}

BatteryReading _reading({required double remainingCapacity}) {
  return BatteryReading(
    deviceAddress: 'A5:C2:37:2F:23:CE',
    batteryId: 1,
    totalVoltage: 26.84,
    current: 0,
    remainingCapacity: remainingCapacity,
    nominalCapacity: 100,
    cycles: 42,
    productionDate: '2024-03-12',
    balanceStatus: const [0, 0],
    protectionStatus: 0,
    softwareVersion: 1,
    stateOfCharge: 1,
    mosfetStatus: 3,
    cellCount: 4,
    ntcCount: 1,
    temperatures: const [24.5],
    cellVoltages: const [3.31, 3.32, 3.30, 3.33],
    averageCellVoltage: 3.315,
    minCellVoltage: 3.30,
    maxCellVoltage: 3.33,
    voltageDifference: 0.03,
    averageTemperature: 24.5,
    isBalanced: true,
    isCharging: false,
    isDischarging: false,
    timestamp: DateTime.utc(2026, 10, 23),
  );
}
