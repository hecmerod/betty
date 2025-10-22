import 'package:flutter/material.dart';

class BatteryPowerConsumptionBadge extends StatelessWidget {
  final double powerWatts;

  const BatteryPowerConsumptionBadge({super.key, required this.powerWatts});

  @override
  Widget build(BuildContext context) {
    final bool isCharging = powerWatts > 0;
    final bool isIdle = powerWatts == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(
        '${powerWatts.abs().toStringAsFixed(0)} W',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isIdle
              ? const Color.fromARGB(255, 241, 241, 241)
              : (isCharging ? const Color(0xFF4ade80) : const Color(0xFFfb923c)),
        ),
      ),
    );
  }
}
