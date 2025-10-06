import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  /// VAPID key para Firebase Cloud Messaging en web
  static String get vapidKey => dotenv.env['FIREBASE_VAPID_KEY'] ?? '';

  /// Tópicos de Firebase Cloud Messaging
  static const String securityAlerts = 'betty_security_alerts';
  static const String systemUpdates = 'betty_system_updates';
  static const String cameraEvents = 'betty_camera_events';

  /// Lista de tópicos por defecto a los que se suscribe la app
  static List<String> get defaultTopics => [securityAlerts, systemUpdates];

  /// Tipos de acciones para mensajes de Firebase
  static const String actionSecurityAlert = 'security_alert';
  static const String actionSystemUpdate = 'system_update';
  static const String actionCameraEvent = 'camera_event';
}
