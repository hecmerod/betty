import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/protected_data.dart';
import '../../../health/presentation/providers/health_monitor_provider.dart';

class ProtectedSection extends StatelessWidget {
  const ProtectedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthMonitorProvider>(
      builder: (context, provider, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🔐 Protected Data',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: provider.isProtectedLoading
                          ? null
                          : provider.fetchProtectedData,
                      icon: provider.isProtectedLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.security),
                      label: Text(
                        provider.isProtectedLoading ? 'Loading...' : 'Test JWT',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (provider.protectedData != null)
                  ProtectedDataCard(data: provider.protectedData!),
                if (provider.protectedError != null)
                  ProtectedErrorCard(error: provider.protectedError!),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProtectedDataCard extends StatelessWidget {
  final ProtectedData data;

  const ProtectedDataCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timestamp = data.timestamp;
    final formattedDate =
        '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final formattedTime =
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'JWT Authentication Success',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(data.message, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(
            'Server: ${data.server}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (data.user.tokenIssuedAt != null) ...[
            Text(
              'Token issued: ${data.user.tokenIssuedAt?.toLocal()}',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (data.user.tokenExpiresAt != null) ...[
            Text(
              'Token expires: ${data.user.tokenExpiresAt?.toLocal()}',
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Response Time: $formattedDate',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                formattedTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProtectedErrorCard extends StatelessWidget {
  final String error;

  const ProtectedErrorCard({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'JWT Authentication Failed',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check JWT configuration in .env file',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}
