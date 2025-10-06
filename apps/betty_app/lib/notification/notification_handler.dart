import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'config/notification_config.dart';
import 'domain/models/notification_data.dart';
import 'presentation/widgets/notification_dialog.dart';

class NotificationHandler {
  static final NotificationHandler _instance = NotificationHandler._internal();

  factory NotificationHandler() => _instance;

  NotificationHandler._internal();

  static NotificationHandler get instance => _instance;

  BuildContext? _context;
  final List<NotificationData> _notificationHistory = [];

  void initialize(BuildContext context) {
    _context = context;
  }

  void handleForegroundMessage(RemoteMessage message) {
    final notificationData = NotificationData.fromFirebaseMessage(message, NotificationSource.foreground);

    _addToHistory(notificationData);

    if (NotificationConfig.showDialogOnForeground) {
      _showNotificationDialog(notificationData);
    }
  }

  void handleBackgroundMessage(RemoteMessage message) {
    final notificationData = NotificationData.fromFirebaseMessage(message, NotificationSource.background);

    _addToHistory(notificationData);
  }

  void handleAppOpenedMessage(RemoteMessage message) {
    final notificationData = NotificationData.fromFirebaseMessage(message, NotificationSource.appOpened);

    _addToHistory(notificationData);

    if (NotificationConfig.showDialogOnAppOpened) {
      _showNotificationDialog(notificationData);
    }
  }

  void handleAppLaunchedMessage(RemoteMessage message) {
    final notificationData = NotificationData.fromFirebaseMessage(message, NotificationSource.appLaunched);

    _addToHistory(notificationData);

    if (NotificationConfig.showDialogOnAppLaunched) {
      _showNotificationDialog(notificationData);
    }
  }

  void _addToHistory(NotificationData notification) {
    if (!NotificationConfig.enableNotificationHistory) return;

    _notificationHistory.insert(0, notification);
    if (_notificationHistory.length > NotificationConfig.maxNotificationHistory) {
      _notificationHistory.removeLast();
    }
  }

  void _showNotificationDialog(NotificationData notification) {
    if (_context != null && _context!.mounted) {
      showDialog(
        context: _context!,
        builder: (context) => NotificationDialog(notification: notification),
      ).then((_) {
        // Auto dismiss if enabled
        if (NotificationConfig.enableDialogAutoDismiss) {
          Future.delayed(NotificationConfig.dialogAutoDismiss, () {
            if (_context != null && _context!.mounted) {
              Navigator.of(_context!).popUntil((route) => route.isFirst);
            }
          });
        }
      });
    }
  }

  List<NotificationData> get notificationHistory => List.unmodifiable(_notificationHistory);

  void clearHistory() {
    _notificationHistory.clear();
  }
}
