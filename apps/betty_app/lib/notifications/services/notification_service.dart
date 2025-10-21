import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📱 Notificación en background: ${message.messageId}');
  debugPrint('   Título: ${message.notification?.title}');
  debugPrint('   Cuerpo: ${message.notification?.body}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _token;
  final List<NotificationModel> _notifications = [];
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _token = await _messaging.getToken();

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      _setupHandlers();
    }
  }

  void _setupHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _addNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _addNotification(message);
    });

    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _addNotification(message);
      }
    });
  }

  void _addNotification(RemoteMessage message) {
    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title,
      body: message.notification?.body,
      receivedAt: DateTime.now(),
      data: message.data,
    );
    _notifications.insert(0, notification);
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCount.value = _notifications.where((n) => !n.read).length;
  }

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      _updateUnreadCount();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(read: true);
    }
    _updateUnreadCount();
  }

  void clearNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _updateUnreadCount();
  }

  void clearAllNotifications() {
    _notifications.clear();
    _updateUnreadCount();
  }

  String? get token => _token;
}
