import 'package:flutter/material.dart';

class StatusButton extends StatelessWidget {
  final IconData icon;
  final String title;

  const StatusButton({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    // Siempre usar grises para botones mock no funcionales
    final color = Colors.grey[400]!;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
              ),
              const SizedBox(height: 4),
              // Espacio invisible para mantener el mismo tamaño que AlarmStatusButton
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
