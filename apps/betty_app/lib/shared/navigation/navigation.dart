import 'package:flutter/material.dart';
import '../../notifications/widgets/notification_snackbar.dart';

class Navigation {
  static final Navigation instance = Navigation._();
  Navigation._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  BuildContext? get context => navigatorKey.currentContext;

  void showNotificationSnackBar({required String? title, required String? body, VoidCallback? onTap}) {
    final ctx = context;
    if (ctx != null) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        NotificationSnackBar(title: title, body: body, onTap: () => onTap?.call(), context: ctx),
      );
    }
  }
}
