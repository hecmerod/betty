import 'package:flutter/material.dart';
import 'dart:ui';

class LightControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOn;
  final Function(bool) onToggle;
  final Color? color;

  const LightControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isOn,
    required this.onToggle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? const Color(0xFF4facfe);

    return GestureDetector(
      onTap: () => onToggle(!isOn),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: isOn ? buttonColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOn ? buttonColor.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: isOn
                  ? [BoxShadow(color: buttonColor.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 36),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  isOn ? 'Encendido' : 'Apagado',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
