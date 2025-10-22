import 'package:flutter/material.dart';
import '../../shared/animations/wave_painter.dart';
import '../../home/widgets/battery_percentage_text.dart';
import '../../home/widgets/battery_power_consumption_badge.dart';

class VerticalBatteryCard extends StatelessWidget {
  final double percentage;
  final double powerWatts;
  final AnimationController waveController;

  const VerticalBatteryCard({
    super.key,
    required this.percentage,
    required this.powerWatts,
    required this.waveController,
  });

  Color _getBatteryColor(double percentage) {
    if (percentage > 50) return const Color(0xFF4ade80);
    if (percentage > 20) return const Color(0xFFfbbf24);
    return const Color(0xFFef4444);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 400,
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
            // Wave background
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedBuilder(
                  animation: waveController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: WavePainter(
                        animation: waveController.value,
                        percentage: percentage / 100,
                        color: _getBatteryColor(percentage),
                        direction: WaveDirection.vertical,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Consumo en la parte superior
                  BatteryPowerConsumptionBadge(powerWatts: powerWatts),
                  // Porcentaje en la parte inferior
                  BatteryPercentageText(percentage: percentage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
