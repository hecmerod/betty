import 'package:flutter/material.dart';

class BatteryPercentageText extends StatelessWidget {
  final double percentage;

  const BatteryPercentageText({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${percentage.toStringAsFixed(0)}%',
      style: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.0,
        shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), offset: const Offset(0, 2), blurRadius: 4)],
      ),
    );
  }
}
