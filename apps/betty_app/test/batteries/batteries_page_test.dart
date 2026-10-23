import 'dart:async';

import 'package:betty_app/batteries/domain/entities/battery_reading.dart';
import 'package:betty_app/batteries/domain/ports/batteries_port.dart';
import 'package:betty_app/batteries/presentation/batteries_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the latest reading for each battery', (tester) async {
    final updates = StreamController<BatteryReading>();
    addTearDown(updates.close);

    final port = _FakeBatteriesPort(
      onReadAll: () async => [
        _reading(remainingCapacity: 86, isCharging: true),
      ],
      onStreamAll: () => updates.stream,
    );

    await tester.pumpWidget(_app(port));
    await tester.pump();

    expect(find.text('Batería 1'), findsOneWidget);
    expect(find.text('86%'), findsOneWidget);
    expect(find.text('Cargando'), findsOneWidget);
    expect(find.text('26,84 V'), findsOneWidget);
    expect(find.text('4,20 A'), findsOneWidget);

    updates.add(
      _reading(remainingCapacity: 50, isCharging: false, isDischarging: true),
    );
    await tester.pump();

    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Descargando'), findsOneWidget);
    expect(find.text('86%'), findsNothing);
  });

  testWidgets('shows a retry action when the batteries cannot be loaded', (
    tester,
  ) async {
    var calls = 0;
    final port = _FakeBatteriesPort(
      onReadAll: () async {
        calls++;
        throw Exception('offline');
      },
      onStreamAll: () => const Stream.empty(),
    );

    await tester.pumpWidget(_app(port));
    await tester.pump();

    expect(find.text('Error al cargar las baterías'), findsOneWidget);
    expect(calls, 1);

    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    await tester.pump();

    expect(calls, 2);
    expect(find.text('Error al cargar las baterías'), findsOneWidget);
  });
}

Widget _app(BatteriesPort port) {
  return RepositoryProvider<BatteriesPort>.value(
    value: port,
    child: const MaterialApp(home: BatteriesPage()),
  );
}

class _FakeBatteriesPort implements BatteriesPort {
  _FakeBatteriesPort({required this.onReadAll, required this.onStreamAll});

  final Future<List<BatteryReading>> Function() onReadAll;
  final Stream<BatteryReading> Function() onStreamAll;

  @override
  Future<List<BatteryReading>> readAllBatteries() => onReadAll();

  @override
  Stream<BatteryReading> streamAllBatteries() => onStreamAll();

  @override
  Future<BatteryReading> readBattery(int batteryId) {
    throw UnimplementedError();
  }

  @override
  Stream<BatteryReading> streamBattery(int batteryId) {
    throw UnimplementedError();
  }
}

BatteryReading _reading({
  required double remainingCapacity,
  required bool isCharging,
  bool isDischarging = false,
}) {
  return BatteryReading(
    deviceAddress: 'A5:C2:37:2F:23:CE',
    batteryId: 1,
    totalVoltage: 26.84,
    current: isCharging ? 4.2 : -3.1,
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
    isCharging: isCharging,
    isDischarging: isDischarging,
    timestamp: DateTime.utc(2026, 10, 23),
  );
}
