import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../notification/config/firebase_config.dart';
import '../di/dependency_injection.dart';
import '../../auth/infrastructure/services/jwt_service.dart';
import '../../notification/notification_handler.dart';
import '../../error/error.dart';

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
    try {
      String? token;

      if (kIsWeb) {
        final vapidKey = FirebaseConfig.vapidKey;
        if (vapidKey.isNotEmpty) {
          token = await _firebaseMessaging.getToken(vapidKey: vapidKey);
        } else {
          ErrorService().reportFirebaseError(
            message: 'Configuración de VAPID key faltante para web',
            technicalDetails: 'vapidKey está vacío en FirebaseConfig',
          );
          return;
        }
      } else {
        token = await _firebaseMessaging.getToken();
      }

      if (token != null) {
        _fcmToken = token;
        await _sendTokenToServer(token);
      } else {
        ErrorService().reportFirebaseError(
          message: 'No se pudo obtener el token FCM',
          technicalDetails: 'Firebase devolvió token null',
        );
      }
    } catch (e, stackTrace) {
      ErrorService().reportFirebaseError(
        message: 'Error al obtener el token de notificaciones',
        technicalDetails: 'Error en _getAndStoreToken: $e',
        stackTrace: stackTrace,
      );
    }
  }

  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen(
      (fcmToken) async {
        try {
          _fcmToken = fcmToken;
          await _sendTokenToServer(fcmToken);
        } catch (e, stackTrace) {
          ErrorService().reportFirebaseError(
            message: 'Error al actualizar el token de notificaciones',
            technicalDetails: 'Error en token refresh: $e',
            stackTrace: stackTrace,
            context: {'newToken': fcmToken},
          );
        }
      },
      onError: (error, stackTrace) {
        ErrorService().reportFirebaseError(
          message: 'Error en el listener de actualización de token',
          technicalDetails: 'Token refresh listener error: $error',
          stackTrace: stackTrace,
        );
      },
    );
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

  Future<void> _sendTokenToServer(String token) async {
    try {
      final jwtToken = JwtService.generateToken();
      await DependencyInjection.apiService.registerFCMToken(token, jwtToken);
    } catch (e, stackTrace) {
      ErrorService().reportNetworkError(
        message:
            'No se pudo sincronizar el token de notificaciones con el servidor. La aplicación continuará funcionando normalmente.',
        technicalDetails: 'Error enviando FCM token: $e',
        stackTrace: stackTrace,
        context: {'token': token, 'service': 'FirebaseNotificationService'},
      );
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e, stackTrace) {
      ErrorService().reportFirebaseError(
        message: 'No se pudo suscribir al tema de notificaciones',
        technicalDetails: 'Error subscribing to topic $topic: $e',
        stackTrace: stackTrace,
        context: {'topic': topic},
      );
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e, stackTrace) {
      ErrorService().reportFirebaseError(
        message: 'No se pudo desuscribir del tema de notificaciones',
        technicalDetails: 'Error unsubscribing from topic $topic: $e',
        stackTrace: stackTrace,
        context: {'topic': topic},
      );
    }
  }

  String? get currentToken => _fcmToken;

  bool get isInitialized => _isInitialized;
}
