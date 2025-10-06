import 'package:flutter/material.dart';
import '../../../core/services/firebase_notification_service.dart';
import '../../config/firebase_config.dart';

class NotificationStatusWidget extends StatefulWidget {
  const NotificationStatusWidget({super.key});

  @override
  State<NotificationStatusWidget> createState() => _NotificationStatusWidgetState();
}

class _NotificationStatusWidgetState extends State<NotificationStatusWidget> {
  final FirebaseNotificationService _notificationService = FirebaseNotificationService.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _notificationService.isInitialized ? Icons.notifications_active : Icons.notifications_off,
                  color: _notificationService.isInitialized ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text('Notificaciones', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _notificationService.isInitialized ? 'Estado: Activas' : 'Estado: Inactivas',
              style: TextStyle(color: _notificationService.isInitialized ? Colors.green : Colors.grey),
            ),
            if (_notificationService.currentToken != null) ...[
              const SizedBox(height: 8),
              Text(
                'Token: ${_notificationService.currentToken!.substring(0, 20)}...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                if (!_notificationService.isInitialized)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _initializeNotifications,
                    icon: _isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.notifications),
                    label: const Text('Activar'),
                  ),
                _buildTopicChip(FirebaseConfig.securityAlerts),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicChip(String topic) {
    return ActionChip(
      label: Text(topic.replaceAll('betty_', '').replaceAll('_', ' ')),
      onPressed: () => _toggleTopic(topic),
      avatar: const Icon(Icons.topic, size: 16),
    );
  }

  Future<void> _initializeNotifications() async {
    setState(() => _isLoading = true);

    try {
      await _notificationService.initialize();

      for (final topic in FirebaseConfig.defaultTopics) {
        await _notificationService.subscribeToTopic(topic);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificaciones activadas correctamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al activar notificaciones: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTopic(String topic) async {
    try {
      await _notificationService.subscribeToTopic(topic);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Suscrito a $topic'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al suscribirse: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
