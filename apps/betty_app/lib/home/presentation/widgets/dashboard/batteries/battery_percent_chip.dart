import 'package:betty_app/home/presentation/widgets/dashboard/batteries/battery_helpers.dart';
import 'package:flutter/material.dart';

class BatteryPercentChip extends StatelessWidget {
  final int percent;

  const BatteryPercentChip({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(gradient: batteryGradient(percent), borderRadius: BorderRadius.circular(12)),
      child: Text(
        '$percent%',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.4),
      ),
    );
  }
}
