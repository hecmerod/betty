import 'error_type.dart';
import 'error_severity.dart';

class AppError {
  final String id;
  final ErrorType type;
  final ErrorSeverity severity;
  final String title;
  final String message;
  final String? technicalDetails;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  AppError({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    this.technicalDetails,
    this.stackTrace,
    DateTime? timestamp,
    this.context,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get shouldShowToUser {
    switch (severity) {
      case ErrorSeverity.info:
      case ErrorSeverity.warning:
      case ErrorSeverity.error:
        return true;
      case ErrorSeverity.critical:
        return true;
    }
  }

  bool get shouldLog {
    return true;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'title': title,
      'message': message,
      'technicalDetails': technicalDetails,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'stackTrace': stackTrace?.toString(),
    };
  }

  @override
  String toString() {
    return 'AppError(id: $id, type: $type, severity: $severity, title: $title, message: $message)';
  }
}
