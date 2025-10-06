import 'package:flutter/material.dart';
import '../../config/notification_config.dart';
import '../../domain/models/notification_data.dart';

class NotificationDialog extends StatelessWidget {
  final NotificationData notification;

  const NotificationDialog({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final dialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NotificationConfig.dialogBorderRadius)),
      title: Row(
        children: [
          Icon(_getSourceIcon(), color: _getSourceColor(), size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(notification.displayTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(notification.displayBody, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Origen', notification.sourceDescription),
                  const SizedBox(height: 8),
                  _buildInfoRow('Tipo', notification.displayType),
                  const SizedBox(height: 8),
                  _buildInfoRow('Recibido', _formatTimestamp(notification.receivedAt)),
                  if (notification.data.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Datos adicionales:',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    ...notification.data.entries.map((entry) => _buildInfoRow(entry.key, entry.value)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar', style: TextStyle(fontSize: 16)),
        ),
      ],
    );

    
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: NotificationConfig.dialogMaxWidth),
      child: NotificationConfig.enableDialogAnimations
          ? AnimatedContainer(duration: NotificationConfig.dialogAnimationDuration, child: dialog)
          : dialog,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
      ],
    );
  }

  IconData _getSourceIcon() {
    switch (notification.source) {
      case NotificationSource.foreground:
        return Icons.notifications_active;
      case NotificationSource.background:
        return Icons.notifications;
      case NotificationSource.appOpened:
        return Icons.open_in_new;
      case NotificationSource.appLaunched:
        return Icons.launch;
    }
  }

  Color _getSourceColor() {
    switch (notification.source) {
      case NotificationSource.foreground:
        return Colors.blue;
      case NotificationSource.background:
        return Colors.orange;
      case NotificationSource.appOpened:
        return Colors.green;
      case NotificationSource.appLaunched:
        return Colors.purple;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
