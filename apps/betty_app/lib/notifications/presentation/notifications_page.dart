import 'package:betty_app/notifications/domain/notification_model.dart';
import 'package:betty_app/notifications/infrastructure/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel>? _notifications;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final notifications = await NotificationService.instance
          .getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudieron cargar las notificaciones');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _Message(text: _error!);

    final notifications = _notifications;
    if (notifications == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notifications.isEmpty) {
      return const _Message(text: 'No hay notificaciones');
    }

    final double gap = MediaQuery.sizeOf(context).height / 80;

    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (_, _) => SizedBox(height: gap),
      itemBuilder: (context, index) =>
          _NotificationTile(notification: notifications[index]),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1E1E1E).withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final title = notification.title?.trim();
    final body = notification.body?.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1E1E1E).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title == null || title.isEmpty ? 'Notificación' : title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: notification.read ? FontWeight.w600 : FontWeight.w700,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          if (body != null && body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _stamp(notification.receivedAt),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

String _stamp(DateTime time) {
  final local = time.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/${local.year} $hour:$minute';
}
