import 'package:flutter/material.dart';
import 'dart:ui';

class BatteryInfoSection extends StatelessWidget {
  final double battery1Percentage;
  final double battery1PowerWatts;
  final double battery2Percentage;
  final double battery2PowerWatts;

  const BatteryInfoSection({
    super.key,
    required this.battery1Percentage,
    required this.battery1PowerWatts,
    required this.battery2Percentage,
    required this.battery2PowerWatts,
  });

  @override
  Widget build(BuildContext context) {
    const totalCapacityAh = 400.0;
    final averagePercentage = (battery1Percentage + battery2Percentage) / 2;
    final totalPower = battery1PowerWatts + battery2PowerWatts;
    final estimatedAh = (averagePercentage / 100) * totalCapacityAh;
    final estimatedHours = totalPower != 0 ? (estimatedAh / (totalPower.abs() / 12.0)).abs() : 0.0;

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen del Sistema',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Primera fila - Porcentajes individuales
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.battery_1_bar_rounded,
                        label: 'Batería 1',
                        value: '${battery1Percentage.toStringAsFixed(0)}%',
                        valueColor: _getBatteryColor(battery1Percentage),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.battery_5_bar_rounded,
                        label: 'Batería 2',
                        value: '${battery2Percentage.toStringAsFixed(0)}%',
                        valueColor: _getBatteryColor(battery2Percentage),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Segunda fila - Estadísticas generales
                _InfoRow(
                  icon: Icons.battery_charging_full_rounded,
                  label: 'Carga Promedio',
                  value: '${averagePercentage.toStringAsFixed(1)}%',
                  valueColor: _getBatteryColor(averagePercentage),
                ),

                const SizedBox(height: 12),

                _InfoRow(
                  icon: Icons.bolt_rounded,
                  label: 'Potencia Total',
                  value: '${totalPower.toStringAsFixed(0)}W',
                  valueColor: totalPower < 0 ? const Color(0xFF4ade80) : const Color(0xFFfb923c),
                ),

                const SizedBox(height: 12),

                _InfoRow(
                  icon: Icons.battery_std_rounded,
                  label: 'Capacidad Disponible',
                  value: '${estimatedAh.toStringAsFixed(0)} Ah',
                ),

                if (totalPower != 0) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    label: totalPower < 0 ? 'Tiempo Estimado' : 'Tiempo de Carga',
                    value: estimatedHours < 100
                        ? '${estimatedHours.toStringAsFixed(1)}h'
                        : '${(estimatedHours / 24).toStringAsFixed(0)}d',
                    valueColor: totalPower < 0 ? Colors.white : const Color(0xFF60a5fa),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBatteryColor(double percentage) {
    if (percentage > 50) return const Color(0xFF4ade80);
    if (percentage > 20) return const Color(0xFFfbbf24);
    return const Color(0xFFef4444);
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoCard({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor ?? Colors.white),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.9))),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor ?? Colors.white),
        ),
      ],
    );
  }
}
