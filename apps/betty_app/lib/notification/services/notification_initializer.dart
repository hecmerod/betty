import '../../core/services/firebase_notification_service.dart';
import '../config/firebase_config.dart';

class NotificationInitializer {
  static Future<void> initialize() async {
    try {
      await FirebaseNotificationService.instance.initialize();
      for (final topic in FirebaseConfig.defaultTopics) {
        await FirebaseNotificationService.instance.subscribeToTopic(topic);
      }
    } catch (e) {
      // Log el error pero permite que la app continue
    }
  }
}
