import 'package:flutter/material.dart';
import '../../notification_handler.dart';

class NotificationWrapper extends StatefulWidget {
  final Widget child;

  const NotificationWrapper({super.key, required this.child});

  @override
  State<NotificationWrapper> createState() => _NotificationWrapperState();
}

class _NotificationWrapperState extends State<NotificationWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationHandler.instance.initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
