class NotificationConfig {
  /// Configuración de permisos de notificaciones
  static const bool requestProvisionalPermission = true;
  static const bool enableAlert = true;
  static const bool enableBadge = true;
  static const bool enableSound = true;

  /// Configuración de comportamiento de diálogos
  static const bool showDialogOnForeground = true;
  static const bool showDialogOnAppOpened = true;
  static const bool showDialogOnAppLaunched = false;

  /// Configuración de historial de notificaciones
  static const int maxNotificationHistory = 50;
  static const bool enableNotificationHistory = true;

  /// Configuración de UI
  static const Duration dialogAutoDismiss = Duration(seconds: 10);
  static const bool enableDialogAutoDismiss = false;

  /// Configuración de presentación
  static const double dialogMaxWidth = 400.0;
  static const double dialogBorderRadius = 16.0;

  /// Configuración de animaciones
  static const Duration dialogAnimationDuration = Duration(milliseconds: 300);
  static const bool enableDialogAnimations = true;
}
