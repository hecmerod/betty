import 'package:flutter/material.dart';

class TripInfoSection extends StatelessWidget {
  final String message;

  const TripInfoSection({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(child: Text(message, style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Solo puedes tener un viaje en progreso a la vez. Finaliza el viaje actual antes de crear uno nuevo.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
