import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../config/firebase_config.dart';
import '../../notification/notification_handler.dart';

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance = FirebaseNotificationService._internal();

  factory FirebaseNotificationService() => _instance;

  FirebaseNotificationService._internal();

  static FirebaseNotificationService get instance => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final notificationSettings = await _requestPermission();

    if (notificationSettings.authorizationStatus == AuthorizationStatus.authorized ||
        notificationSettings.authorizationStatus == AuthorizationStatus.provisional) {
      await _ensureApnsToken();
      await _getAndStoreToken();
      _setupTokenRefreshListener();
      _setupMessageHandlers();
      _isInitialized = true;
    }
  }

  Future<NotificationSettings> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );
    return settings;
  }

  Future<void> _ensureApnsToken() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _firebaseMessaging.getAPNSToken();
    }
  }

  Future<void> _getAndStoreToken() async {
    String? token;

    if (kIsWeb) {
      final vapidKey = FirebaseConfig.vapidKey;
      if (vapidKey.isNotEmpty) {
        token = await _firebaseMessaging.getToken(vapidKey: vapidKey);
      } else {
        return;
      }
    } else {
      token = await _firebaseMessaging.getToken();
    }

    if (token != null) {
      _fcmToken = token;
      await _sendTokenToServer(token);
    }
  }

  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((fcmToken) async {
      _fcmToken = fcmToken;
      await _sendTokenToServer(fcmToken);
    });
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        NotificationHandler.instance.handleAppLaunchedMessage(message);
        _handleMessage(message);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationHandler.instance.handleForegroundMessage(message);
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationHandler.instance.handleAppOpenedMessage(message);
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;

    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'security_alert':
          _handleSecurityAlert(message);
          break;
        case 'system_update':
          _handleSystemUpdate(message);
          break;
      }
    }
  }

  void _handleSecurityAlert(RemoteMessage message) {}

  void _handleSystemUpdate(RemoteMessage message) {}

  Future<void> _sendTokenToServer(String token) async {}

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  String? get currentToken => _fcmToken;

  bool get isInitialized => _isInitialized;
}
