import 'package:flutter/material.dart';

class AppBarNotificationsIcon extends StatelessWidget {
  const AppBarNotificationsIcon({
    super.key,
    required this.onPressed,
    this.selected = false,
  });

  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notificaciones',
      icon: Icon(
        selected ? Icons.notifications : Icons.notifications_outlined,
        size: 30,
        color: const Color(0xFF1E1E1E),
      ),
      onPressed: onPressed,
    );
  }
}
