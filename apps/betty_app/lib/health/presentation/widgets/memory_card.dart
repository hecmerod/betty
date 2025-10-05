import 'package:flutter/material.dart';
import '../../domain/entities/health_data.dart';

class MemoryCard extends StatelessWidget {
  final HealthData healthData;

  const MemoryCard({super.key, required this.healthData});

  Color _getMemoryColor() {
    final usagePercentage = healthData.memory.usagePercentage;
    if (usagePercentage > 85) return Colors.red;
    if (usagePercentage > 70) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memory = healthData.memory;
    final usagePercentage = memory.usagePercentage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.memory, size: 32, color: _getMemoryColor()),
                const SizedBox(width: 12),
                Text(
                  'Memory Usage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${usagePercentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: _getMemoryColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: usagePercentage / 100,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: _getMemoryColor(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Used: ${memory.used} MB'),
                Text('Total: ${memory.total} MB'),
                Text('RSS: ${memory.rss} MB'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
