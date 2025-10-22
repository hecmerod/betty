import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class BatteryStatusCard extends StatefulWidget {
  const BatteryStatusCard({super.key});

  @override
  State<BatteryStatusCard> createState() => _BatteryStatusCardState();
}

class _BatteryStatusCardState extends State<BatteryStatusCard> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double batteryPercentage = 76.5;
    const double powerWatts = 0.0;
    final bool isCharging = powerWatts > 0;
    final bool isIdle = powerWatts == 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 150,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: [
            // Olas animadas en el fondo
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: WavePainter(
                        animation: _waveController.value,
                        percentage: batteryPercentage / 100,
                        color: _getBatteryColor(batteryPercentage),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Contenido por encima de las olas
            LayoutBuilder(
              builder: (context, constraints) {
                final shouldBeInside = batteryPercentage >= 40;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: shouldBeInside ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${batteryPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${powerWatts.abs().toStringAsFixed(0)} W',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isIdle
                                ? const Color(0xFF9ca3af)
                                : (isCharging ? const Color(0xFF4ade80) : const Color(0xFFfb923c)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getBatteryColor(double percentage) {
    const red = Color(0xFFef4444);
    const yellow = Color(0xFFfbbf24);
    const green = Color(0xFF4ade80);

    if (percentage <= 30) {
      return Color.lerp(red.withValues(alpha: 0.8), red, percentage / 30) ?? red;
    } else if (percentage <= 60) {
      final t = (percentage - 30) / 30;
      return Color.lerp(red, yellow, t) ?? yellow;
    } else {
      final t = (percentage - 60) / 40;
      return Color.lerp(yellow, green, t) ?? green;
    }
  }
}

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
