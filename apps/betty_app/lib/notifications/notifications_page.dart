import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/notification_service.dart';
import 'models/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _notificationService = NotificationService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_notificationService.notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  setState(() {
                    _notificationService.markAllAsRead();
                  });
                } else if (value == 'clear_all') {
                  setState(() {
                    _notificationService.clearAllNotifications();
                  });
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(children: [Icon(Icons.done_all), SizedBox(width: 8), Text('Marcar todo como leído')]),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(children: [Icon(Icons.delete_sweep), SizedBox(width: 8), Text('Eliminar todo')]),
                ),
              ],
            ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _notificationService.unreadCount,
        builder: (context, _, __) {
          final notifications = _notificationService.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay notificaciones',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationItem(
                notification: notification,
                onTap: () {
                  setState(() {
                    _notificationService.markAsRead(notification.id);
                  });
                },
                onDismissed: () {
                  setState(() {
                    _notificationService.clearNotification(notification.id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notificación eliminada'), duration: Duration(seconds: 2)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _NotificationItem({required this.notification, required this.onTap, required this.onDismissed});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: notification.read ? Colors.grey[200] : Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications,
            color: notification.read ? Colors.grey[600] : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          notification.title ?? 'Sin título',
          style: TextStyle(fontWeight: notification.read ? FontWeight.normal : FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.body != null) ...[
              const SizedBox(height: 4),
              Text(notification.body!, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 4),
            Text(_formatDate(notification.receivedAt), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        trailing: !notification.read
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
