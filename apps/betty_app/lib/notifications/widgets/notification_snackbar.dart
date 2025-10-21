import 'package:flutter/material.dart';

class NotificationSnackBar extends SnackBar {
  NotificationSnackBar({
    super.key,
    required String? title,
    required String? body,
    required VoidCallback onTap,
    required BuildContext context,
  }) : super(
         content: _NotificationContent(title: title, body: body),
         duration: const Duration(seconds: 4),
         behavior: SnackBarBehavior.floating,
         backgroundColor: Theme.of(context).colorScheme.primaryContainer,
         margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 160, left: 10, right: 10),
         action: SnackBarAction(label: 'Ver', textColor: Theme.of(context).colorScheme.primary, onPressed: onTap),
       );
}

class _NotificationContent extends StatelessWidget {
  final String? title;
  final String? body;

  const _NotificationContent({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ?? 'Nueva notificación';
    final displayBody = body ?? '';
    final textColor = Theme.of(context).colorScheme.onPrimaryContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
        ),
        if (displayBody.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            displayBody,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.8)),
          ),
        ],
      ],
    );
  }
}
