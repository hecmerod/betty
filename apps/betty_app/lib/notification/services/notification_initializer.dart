import 'package:betty_app/notification/config/firebase_config.dart';

import 'firebase_notification_service.dart';
import '../../shared/error/error.dart';

class NotificationInitializer {
  static Future<void> initialize() async {
    try {
      await FirebaseNotificationService.instance.initialize();
      for (final topic in FirebaseConfig.defaultTopics) {
        await FirebaseNotificationService.instance.subscribeToTopic(topic);
      }
    } catch (e, stackTrace) {
      ErrorService().reportFirebaseError(
        message: 'Error al inicializar el servicio de notificaciones',
        technicalDetails: 'NotificationInitializer error: $e',
        stackTrace: stackTrace,
      );
    }
  }
}
