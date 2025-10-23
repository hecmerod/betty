import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/notification_model.dart';
import '../repository/notification_repository.dart';
import '../../shared/navigation/navigation.dart';
import '../../shared/navigation/bloc/navigation_bloc.dart';
import '../../shared/navigation/bloc/navigation_event.dart';
import '../../shared/navigation/routes.dart';
import '../../shared/services/api_service.dart';

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
  final _apiService = ApiService.instance;
  String? _token;
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  Future<void> initialize() async {
    await _loadUnreadCount();

    final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _token = await _messaging.getToken();

      await _registerToken(_token!);

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      _setupHandlers();
    }
  }

  Future<void> _registerToken(String fcmToken) async {
    await _apiService.post('/notifications/register', body: {'token': fcmToken, 'platform': 'flutter'});
  }

  Future<void> _loadUnreadCount() async {
    unreadCount.value = await _repository.getUnreadCount();
  }

  void _setupHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _addNotification(message);
      _showNotificationSnackBar(message);
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

  void _showNotificationSnackBar(RemoteMessage message) {
    Navigation.instance.showNotificationSnackBar(
      title: message.notification?.title,
      body: message.notification?.body,
      onTap: () {
        final context = Navigation.instance.context;
        if (context != null) {
          context.read<NavigationBloc>().add(const NavigateToPage(Routes.notifications));
        }
      },
    );
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
