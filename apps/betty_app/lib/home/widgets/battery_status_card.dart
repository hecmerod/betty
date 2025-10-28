import 'package:betty_app/shared/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/animations/wave_painter.dart';
import '../../shared/navigation/bloc/navigation_bloc.dart';
import '../../shared/navigation/bloc/navigation_event.dart';
import 'battery_percentage_text.dart';
import 'battery_power_consumption_badge.dart';

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
    const double batteryPercentage = 62;
    const double powerWatts = 0.0;

    return GestureDetector(
      onTap: () {
        context.read<NavigationBloc>().add(const NavigateToPage(Routes.batteryDetail));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 150,
          width: double.infinity,
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
                        const BatteryPercentageText(percentage: batteryPercentage),
                        const BatteryPowerConsumptionBadge(powerWatts: powerWatts),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
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
