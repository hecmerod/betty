import 'package:flutter/material.dart';
import 'dart:math' as math;

class WavePainter extends CustomPainter {
  final double animation;
  final double percentage;
  final Color color;

  WavePainter({required this.animation, required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = Path();

    final waveAmplitude = 10.0;
    // Calcular el ancho que debe ocupar según el porcentaje (desde izquierda)
    final waveWidth = (size.width + waveAmplitude) * percentage;

    // Amplitud de la ola

    // Posición del borde de la ola (vertical)
    final centerX = waveWidth;

    // Empezar desde la esquina inferior izquierda
    path.moveTo(0, 0);
    path.lineTo(0, size.height);

    // Dibujar la ola vertical (de abajo hacia arriba)
    for (double i = size.height; i >= 0; i--) {
      final y = i;
      final x = centerX + math.sin((i / 30) + (animation * 2 * math.pi)) * waveAmplitude;
      path.lineTo(x, y);
    }

    // Cerrar el path
    path.close();

    canvas.drawPath(path, paint);

    // Segunda ola con más opacidad
    final paint2 = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, 0);
    path2.lineTo(0, size.height);

    for (double i = size.height; i >= 0; i--) {
      final y = i;
      final x = centerX + math.sin((i / 25) + (animation * 2 * math.pi) + 1) * (waveAmplitude * 0.8);
      path2.lineTo(x, y);
    }

    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}
