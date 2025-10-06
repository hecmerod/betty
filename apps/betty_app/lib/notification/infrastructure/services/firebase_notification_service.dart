import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../shared/error/error.dart';

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance = FirebaseNotificationService._internal();

  factory FirebaseNotificationService() => _instance;

  FirebaseNotificationService._internal();

  static FirebaseNotificationService get instance => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? token;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final notificationSettings = await _requestPermission();

    if (notificationSettings.authorizationStatus == AuthorizationStatus.authorized ||
        notificationSettings.authorizationStatus == AuthorizationStatus.provisional) {
      await _getAndStoreToken();
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

  Future<void> _getAndStoreToken() async {
    token = await _firebaseMessaging.getToken();

    if (token != null) {
      await DependencyInjection.notificationApiService.sendDeviceToken(token!);
    } else {
      ErrorService().reportFirebaseError(
        message: 'No se pudo obtener el token FCM',
        technicalDetails: 'Firebase devolvió token null',
      );
    }
  }

  String? get currentToken => token;

  bool get isInitialized => _isInitialized;
}
