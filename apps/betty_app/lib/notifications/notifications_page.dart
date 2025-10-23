import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'models/notification_model.dart';
import 'widgets/notification_actions_menu.dart';
import 'widgets/notification_item.dart';
import '../shared/widgets/secondary_page_app_bar.dart';

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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: SecondaryPageAppBar(
        title: 'Notificaciones',
        actions: [
          if (_notifications.isNotEmpty)
            NotificationActionsMenu(
              onMarkAllRead: () async {
                await _notificationService.markAllAsRead();
                await _loadNotifications();
              },
              onClearAll: () async {
                await _notificationService.clearAllNotifications();
                await _loadNotifications();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : ValueListenableBuilder<int>(
                valueListenable: _notificationService.unreadCount,
                builder: (context, _, _) {
                  if (_notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
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
                        child: NotificationItem(
                          notification: notification,
                          onTap: () async {
                            await _notificationService.markAsRead(notification.id);
                            await _loadNotifications();
                          },
                          onDismissed: () async {
                            await _notificationService.clearNotification(notification.id);
                            await _loadNotifications();
                          },
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
