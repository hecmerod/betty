import 'package:flutter/material.dart';

class SensorHeading extends StatelessWidget {
  const SensorHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF43e97b), Color(0xFF38f9d7)]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'SENSORES',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), letterSpacing: 1.5),
        ),
      ],
    );
  }
}
