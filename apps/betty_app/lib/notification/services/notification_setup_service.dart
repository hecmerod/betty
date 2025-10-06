import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';
import '../notification_handler.dart';
import '../config/firebase_config.dart';
import '../../shared/error/error.dart';
import 'firebase_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationHandler.instance.handleBackgroundMessage(message);
}

class NotificationSetupService {
  static Future<void> initialize() async {
    try {
      // Inicializar Firebase
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      // Configurar handler para mensajes en background
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Inicializar el servicio de notificaciones
      await FirebaseNotificationService.instance.initialize();

      // Suscribirse a los temas por defecto
      for (final topic in FirebaseConfig.defaultTopics) {
        await FirebaseNotificationService.instance.subscribeToTopic(topic);
      }
    } catch (e, stackTrace) {
      ErrorService().reportFirebaseError(
        message: 'Error crítico al inicializar el sistema de notificaciones',
        technicalDetails: 'NotificationSetupService error: $e',
        stackTrace: stackTrace,
      );
    }
  }
}
