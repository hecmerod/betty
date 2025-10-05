import 'package:flutter/material.dart';
import '../../domain/entities/health_data.dart';

class UptimeCard extends StatelessWidget {
  final HealthData healthData;

  const UptimeCard({super.key, required this.healthData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule, size: 32),
        title: const Text('Uptime'),
        subtitle: Text(healthData.formattedUptime),
        trailing: Text(
          '${healthData.uptime.toStringAsFixed(1)}s',
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}
