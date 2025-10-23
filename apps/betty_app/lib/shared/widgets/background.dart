import 'package:flutter/material.dart';
import 'dart:math' as math;

class Background extends StatefulWidget {
  const Background({super.key});

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WaveBackgroundPainter(animation: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class WaveBackgroundPainter extends CustomPainter {
  final double animation;

  WaveBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo base blanco
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);

    // Configuración de las olas
    final paint1 = Paint()
      ..color = const Color(0xFF6366f1).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = const Color(0xFF8b5cf6).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final paint3 = Paint()
      ..color = const Color(0xFFec4899).withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    // Dibujar múltiples capas de olas
    _drawWave(canvas, size, paint1, animation, 0.0, 40, 0.5);
    _drawWave(canvas, size, paint2, animation, 0.3, 50, 0.7);
    _drawWave(canvas, size, paint3, animation, 0.6, 60, 0.9);
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    Paint paint,
    double animation,
    double offset,
    double amplitude,
    double frequency,
  ) {
    final path = Path();
    final waveHeight = size.height * 0.7;

    path.moveTo(0, waveHeight);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          waveHeight +
          math.sin((x / size.width * 2 * math.pi * frequency) + (animation * 2 * math.pi) + (offset * math.pi)) *
              amplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
