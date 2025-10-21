import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repository/notification_repository.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final notification = NotificationModel(
    id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    title: message.notification?.title,
    body: message.notification?.body,
    receivedAt: DateTime.now(),
    data: message.data,
  );
  await NotificationRepository().insert(notification);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final _repository = NotificationRepository();
  String? _token;
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  Future<void> initialize() async {
    await _loadUnreadCount();

    final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _token = await _messaging.getToken();

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      _setupHandlers();
    }
  }

  Future<void> _loadUnreadCount() async {
    unreadCount.value = await _repository.getUnreadCount();
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

  Future<void> _addNotification(RemoteMessage message) async {
    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title,
      body: message.notification?.body,
      receivedAt: DateTime.now(),
      data: message.data,
    );
    await _repository.insert(notification);
    await _loadUnreadCount();
  }

  Future<List<NotificationModel>> getNotifications() async {
    return await _repository.getAll();
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    await _loadUnreadCount();
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    await _loadUnreadCount();
  }

  Future<void> clearNotification(String id) async {
    await _repository.delete(id);
    await _loadUnreadCount();
  }

  Future<void> clearAllNotifications() async {
    await _repository.deleteAll();
    await _loadUnreadCount();
  }

  String? get token => _token;
}
