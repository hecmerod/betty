import 'package:flutter/material.dart';
import '../../domain/entities/health_data.dart';

class TimestampCard extends StatelessWidget {
  final HealthData healthData;

  const TimestampCard({super.key, required this.healthData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timestamp = healthData.timestamp;
    final formattedDate =
        '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final formattedTime =
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.access_time, size: 32),
        title: const Text('Last Updated'),
        subtitle: Text(formattedDate),
        trailing: Text(formattedTime, style: theme.textTheme.bodyLarge),
      ),
    );
  }
}
