import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  static String get vapidKey => dotenv.env['FIREBASE_VAPID_KEY'] ?? '';

  static const String securityAlerts = 'betty_security_alerts';
  static const String systemUpdates = 'betty_system_updates';
  static const String cameraEvents = 'betty_camera_events';

  static List<String> get defaultTopics => [securityAlerts, systemUpdates];

  static const String actionSecurityAlert = 'security_alert';
  static const String actionSystemUpdate = 'system_update';
  static const String actionCameraEvent = 'camera_event';
}
