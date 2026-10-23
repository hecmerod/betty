import 'package:betty_app/home/presentation/widgets/dashboard/batteries/battery_helpers.dart';
import 'package:flutter/material.dart';

class BatteryGlyph extends StatelessWidget {
  final int? percent;
  final bool charging;

  const BatteryGlyph({super.key, required this.percent, required this.charging});

  @override
  Widget build(BuildContext context) {
    final int? charge = percent;
    if (charge == null) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF1E1E1E).withValues(alpha: 0.08)),
        child: const Icon(Icons.battery_std, color: Color(0xFF1E1E1E), size: 20),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: batteryGradient(charge)),
      child: Icon(batteryIconFor(charge, charging), color: Colors.white, size: 20),
    );
  }
}
