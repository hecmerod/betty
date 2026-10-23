import 'package:betty_app/core/navigation/application/navigation_bloc/navigation_bloc.dart';
import 'package:betty_app/core/navigation/application/navigation_bloc/navigation_event.dart';
import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _BatteryPack {
  const _BatteryPack({required this.percent, required this.isCharging});

  final int percent;
  final bool isCharging;
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

class BatteryButton extends StatelessWidget {
  const BatteryButton({super.key});

  static const List<_BatteryPack> _packs = [
    _BatteryPack(percent: 86, isCharging: true),
    _BatteryPack(percent: 74, isCharging: false),
  ];

  int get _combinedPercent => (_packs.map((pack) => pack.percent).reduce((a, b) => a + b) / _packs.length).round();

  bool get _anyCharging => _packs.any((pack) => pack.isCharging);

  @override
  Widget build(BuildContext context) {
    final double pillHeight = MediaQuery.sizeOf(context).height / 12;
    final int percent = _combinedPercent;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 12, spreadRadius: 2)],
      ),
      child: GestureDetector(
        onTap: () => context.read<NavigationBloc>().add(const NavigateToPage(Routes.batteries)),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: pillHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _BatteryGlyph(percent: percent, charging: _anyCharging),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Baterías',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                _PercentChip(percent: percent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BatteryGlyph extends StatelessWidget {
  final int percent;
  final bool charging;

  const _BatteryGlyph({required this.percent, required this.charging});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: _chargeGradient(percent)),
      child: Icon(_iconFor(percent, charging), color: Colors.white, size: 20),
    );
  }
}

class _PercentChip extends StatelessWidget {
  final int percent;

  const _PercentChip({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(gradient: _chargeGradient(percent), borderRadius: BorderRadius.circular(12)),
      child: Text(
        '$percent%',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.4),
      ),
    );
  }
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
