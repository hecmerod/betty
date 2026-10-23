import 'package:betty_app/batteries/application/batteries_bloc/batteries_bloc.dart';
import 'package:betty_app/batteries/application/batteries_bloc/batteries_state.dart';
import 'package:betty_app/batteries/domain/entities/battery_reading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _ink = Color(0xFF1E1E1E);

class BatteryReadingCard extends StatelessWidget {
  const BatteryReadingCard({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatteriesBloc, BatteriesState>(
      builder: (context, state) {
        if (index >= state.readings.length) return const SizedBox.shrink();
        return _BatteryReadingCardBody(reading: state.readings[index]);
      },
    );
  }
}

class _BatteryReadingCardBody extends StatelessWidget {
  const _BatteryReadingCardBody({required this.reading});

  final BatteryReading reading;

  @override
  Widget build(BuildContext context) {
    final percent = _chargePercent(reading);
    final gradient = _chargeGradient(percent);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _ink.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _BatteryGlyph(percent: percent, charging: reading.isCharging),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Batería ${reading.batteryId}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _statusLabel(reading),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(reading),
                      ),
                    ),
                  ],
                ),
              ),
              _PercentChip(percent: percent, gradient: gradient),
            ],
          ),
          const SizedBox(height: 16),
          _ChargeBar(percent: percent, gradient: gradient),
          if (reading.protectionStatus != 0) ...[
            const SizedBox(height: 16),
            const _ProtectionNotice(),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Tensión',
                  value: '${_format(reading.totalVoltage, 2)} V',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Metric(
                  label: 'Corriente',
                  value: '${_format(reading.current, 2)} A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Temperatura',
                  value: '${_format(reading.averageTemperature, 1)} °C',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Metric(
                  label: 'Capacidad',
                  value:
                      '${_format(reading.remainingCapacity, 1)} / ${_format(reading.nominalCapacity, 1)} Ah',
                ),
              ),
            ],
          ),
          if (reading.cellVoltages.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Celdas (${reading.cellVoltages.length})',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
            const SizedBox(height: 8),
            _CellVoltages(reading: reading),
          ],
          const SizedBox(height: 16),
          Text(
            _footer(reading),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _ink.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _ink.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _ink.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _CellVoltages extends StatelessWidget {
  const _CellVoltages({required this.reading});

  final BatteryReading reading;

  @override
  Widget build(BuildContext context) {
    final highlightSpread = !reading.isBalanced;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var index = 0; index < reading.cellVoltages.length; index++)
          _CellChip(
            index: index + 1,
            voltage: reading.cellVoltages[index],
            isLowest:
                highlightSpread &&
                reading.cellVoltages[index] == reading.minCellVoltage,
            isHighest:
                highlightSpread &&
                reading.cellVoltages[index] == reading.maxCellVoltage,
          ),
      ],
    );
  }
}

class _CellChip extends StatelessWidget {
  const _CellChip({
    required this.index,
    required this.voltage,
    required this.isLowest,
    required this.isHighest,
  });

  final int index;
  final double voltage;
  final bool isLowest;
  final bool isHighest;

  @override
  Widget build(BuildContext context) {
    final Color background = isLowest
        ? const Color(0xFFFFE8EA)
        : isHighest
        ? const Color(0xFFE5FBF1)
        : _ink.withValues(alpha: 0.04);

    return Container(
      width: 76,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$index',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _ink.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_format(voltage, 3)} V',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectionNotice extends StatelessWidget {
  const _ProtectionNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Protección activa',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE11D48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BatteryGlyph extends StatelessWidget {
  const _BatteryGlyph({required this.percent, required this.charging});

  final int percent;
  final bool charging;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _chargeGradient(percent),
      ),
      child: Icon(_iconFor(percent, charging), color: Colors.white, size: 22),
    );
  }
}

class _PercentChip extends StatelessWidget {
  const _PercentChip({required this.percent, required this.gradient});

  final int percent;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$percent%',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ChargeBar extends StatelessWidget {
  const _ChargeBar({required this.percent, required this.gradient});

  final int percent;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    final factor = (percent.clamp(0, 100)) / 100;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 8,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: _ink.withValues(alpha: 0.08)),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: factor,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: gradient),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int _chargePercent(BatteryReading reading) {
  if (reading.nominalCapacity <= 0) return 0;
  final percent = (reading.remainingCapacity / reading.nominalCapacity) * 100;
  return percent.round().clamp(0, 100);
}

LinearGradient _chargeGradient(int percent) {
  if (percent <= 20) {
    return const LinearGradient(colors: [Color(0xFFff6b6b), Color(0xFFee5a6f)]);
  }
  if (percent <= 50) {
    return const LinearGradient(colors: [Color(0xFFfa709a), Color(0xFFfee140)]);
  }
  return const LinearGradient(colors: [Color(0xFF43e97b), Color(0xFF38f9d7)]);
}

IconData _iconFor(int percent, bool charging) {
  if (charging) return Icons.battery_charging_full;
  if (percent <= 10) return Icons.battery_0_bar;
  if (percent <= 25) return Icons.battery_1_bar;
  if (percent <= 40) return Icons.battery_2_bar;
  if (percent <= 55) return Icons.battery_3_bar;
  if (percent <= 70) return Icons.battery_4_bar;
  if (percent <= 85) return Icons.battery_5_bar;
  if (percent < 100) return Icons.battery_6_bar;
  return Icons.battery_full;
}

String _statusLabel(BatteryReading reading) {
  if (reading.isCharging) return 'Cargando';
  if (reading.isDischarging) return 'Descargando';
  return 'En reposo';
}

Color _statusColor(BatteryReading reading) {
  if (reading.isCharging) return const Color(0xFF14915A);
  if (reading.isDischarging) return const Color(0xFFC2410C);
  return _ink.withValues(alpha: 0.55);
}

String _footer(BatteryReading reading) {
  final balance = reading.isBalanced ? 'Equilibrada' : 'Desequilibrada';
  final difference = (reading.voltageDifference * 1000).round();
  final balanceLabel = reading.isBalanced
      ? balance
      : '$balance · $difference mV';
  return '$balanceLabel · ${reading.cycles} ciclos · ${reading.productionDate}';
}

String _format(double value, int decimals) {
  return value.toStringAsFixed(decimals).replaceAll('.', ',');
}
