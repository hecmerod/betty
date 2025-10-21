import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationData {
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final String? type;
  final DateTime receivedAt;
  final NotificationSource source;

  NotificationData({
    required this.title,
    required this.body,
    required this.data,
    required this.type,
    required this.receivedAt,
    required this.source,
  });

  factory NotificationData.fromFirebaseMessage(RemoteMessage message, NotificationSource source) {
    return NotificationData(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      type: message.data['type'],
      receivedAt: DateTime.now(),
      source: source,
    );
  }

  String get displayTitle => title ?? 'Notificación';
  String get displayBody => body ?? 'Sin contenido';
  String get displayType => type ?? 'general';

  String get sourceDescription {
    switch (source) {
      case NotificationSource.foreground:
        return 'Recibida en primer plano';
      case NotificationSource.background:
        return 'Recibida en segundo plano';
      case NotificationSource.appOpened:
        return 'App abierta desde notificación';
      case NotificationSource.appLaunched:
        return 'App iniciada desde notificación';
    }
  }
}

enum NotificationSource { foreground, background, appOpened, appLaunched }
