import 'package:betty_app/batteries/domain/entities/battery_reading.dart';
import 'package:betty_app/batteries/domain/ports/batteries_port.dart';
import 'package:betty_app/home/application/home_batteries_bloc/home_batteries_bloc.dart';
import 'package:betty_app/home/application/home_batteries_bloc/home_batteries_event.dart';
import 'package:betty_app/home/presentation/widgets/app_bar/batteries/battery_percent_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads both batteries once and shows their combined charge', (
    tester,
  ) async {
    var calls = 0;
    final port = _FakeBatteriesPort(
      onReadAll: () async {
        calls++;
        return [
          _reading(batteryId: 1, remainingCapacity: 80, isCharging: true),
          _reading(batteryId: 2, remainingCapacity: 40, isCharging: false),
        ];
      },
    );

    await tester.pumpWidget(
      RepositoryProvider<BatteriesPort>.value(
        value: port,
        child: BlocProvider(
          create: (context) =>
              HomeBatteriesBloc(batteriesPort: context.read<BatteriesPort>())
                ..add(const LoadHomeBatteries()),
          child: MaterialApp(
            home: Scaffold(body: BatteryPercentChip(onTap: () {})),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('60%'), findsOneWidget);
    expect(find.text('Baterías'), findsNothing);
    expect(find.byIcon(Icons.battery_charging_full), findsNothing);
    expect(calls, 1);

    await tester.pump();
    expect(calls, 1);
  });
}

class _FakeBatteriesPort implements BatteriesPort {
  _FakeBatteriesPort({required this.onReadAll});

  final Future<List<BatteryReading>> Function() onReadAll;

  @override
  Future<List<BatteryReading>> readAllBatteries() => onReadAll();

  @override
  Future<BatteryReading> readBattery(int batteryId) {
    throw UnimplementedError();
  }

  @override
  Stream<BatteryReading> streamAllBatteries() => const Stream.empty();

  @override
  Stream<BatteryReading> streamBattery(int batteryId) => const Stream.empty();
}

BatteryReading _reading({
  required int batteryId,
  required double remainingCapacity,
  required bool isCharging,
}) {
  return BatteryReading(
    deviceAddress: 'A5:C2:37:2F:23:CE',
    batteryId: batteryId,
    totalVoltage: 26.84,
    current: isCharging ? 4.2 : 0,
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
    isDischarging: false,
    timestamp: DateTime.utc(2026, 10, 23),
  );
}
