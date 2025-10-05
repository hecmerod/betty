import 'package:flutter/material.dart';
import '../../domain/entities/health_data.dart';

class StatusCard extends StatelessWidget {
  final HealthData? healthData;

  const StatusCard({super.key, this.healthData});

  Color _getStatusColor() {
    if (healthData?.isHealthy == true) {
      return Colors.green;
    }
    return Colors.red;
  }

  IconData _getStatusIcon() {
    if (healthData?.isHealthy == true) {
      return Icons.check_circle;
    }
    return Icons.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(_getStatusIcon(), size: 64, color: _getStatusColor()),
            const SizedBox(height: 16),
            Text('Server Status', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              healthData?.status.toUpperCase() ?? 'UNKNOWN',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: _getStatusColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
