import 'package:flutter/material.dart';
import 'dart:ui';

class NotificationActionsMenu extends StatelessWidget {
  final VoidCallback onMarkAllRead;
  final VoidCallback onClearAll;

  const NotificationActionsMenu({super.key, required this.onMarkAllRead, required this.onClearAll});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E1E).withValues(alpha: 0.1), width: 1.5),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF1E1E1E)),
            onSelected: (value) {
              if (value == 'mark_all_read') {
                onMarkAllRead();
              } else if (value == 'clear_all') {
                onClearAll();
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
                child: Row(children: [Icon(Icons.delete_sweep_rounded), SizedBox(width: 8), Text('Eliminar todo')]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
