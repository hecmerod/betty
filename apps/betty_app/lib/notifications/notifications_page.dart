import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'services/notification_service.dart';
import 'models/notification_model.dart';
import '../shared/theme/app_theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _notificationService = NotificationService.instance;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    _notifications = await _notificationService.getNotifications();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_notifications.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                    onSelected: (value) async {
                      if (value == 'mark_all_read') {
                        await _notificationService.markAllAsRead();
                        await _loadNotifications();
                      } else if (value == 'clear_all') {
                        await _notificationService.clearAllNotifications();
                        await _loadNotifications();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'mark_all_read',
                        child: Row(
                          children: [Icon(Icons.done_all_rounded), SizedBox(width: 8), Text('Marcar todo como leído')],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          children: [Icon(Icons.delete_sweep_rounded), SizedBox(width: 8), Text('Eliminar todo')],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : ValueListenableBuilder<int>(
                  valueListenable: _notificationService.unreadCount,
                  builder: (context, _, __) {
                    if (_notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.notifications_off_rounded, size: 80, color: Colors.white),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No hay notificaciones',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cuando recibas notificaciones\naparecerán aquí',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _NotificationItem(
                            notification: notification,
                            onTap: () async {
                              await _notificationService.markAsRead(notification.id);
                              await _loadNotifications();
                            },
                            onDismissed: () async {
                              await _notificationService.clearNotification(notification.id);
                              await _loadNotifications();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Notificación eliminada'),
                                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final Future<void> Function() onTap;
  final Future<void> Function() onDismissed;

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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFff6b6b), Color(0xFFee5a6f)]),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(notification.read ? 0.7 : 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: notification.read ? Colors.white.withValues(alpha: 0.3) : Colors.white,
                width: notification.read ? 1 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: notification.read
                      ? Colors.black.withValues(alpha: 0.05)
                      : AppTheme.primaryGradientMiddle.withValues(alpha: 0.2),
                  blurRadius: notification.read ? 8 : 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: notification.read
                      ? LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400])
                      : AppTheme.alarmsGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!notification.read)
                      BoxShadow(
                        color: const Color(0xFFfa709a).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Icon(Icons.notifications_rounded, color: Colors.white, size: 24),
              ),
              title: Text(
                notification.title ?? 'Sin título',
                style: TextStyle(
                  fontWeight: notification.read ? FontWeight.w600 : FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.body != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      notification.body!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(notification.receivedAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: !notification.read
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: AppTheme.alarmsGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFfa709a).withValues(alpha: 0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    )
                  : null,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}
