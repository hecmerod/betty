import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../models/notification_model.dart';
import '../../shared/theme/app_theme.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final Future<void> Function() onTap;
  final Future<void> Function() onDismissed;

  const NotificationItem({super.key, required this.notification, required this.onTap, required this.onDismissed});

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
                child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 24),
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
