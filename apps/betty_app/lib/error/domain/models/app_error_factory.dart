import 'error_type.dart';
import 'error_severity.dart';
import 'app_error.dart';

class AppErrorFactory {
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static AppError network({
    required String message,
    String? technicalDetails,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: _generateId(),
      type: ErrorType.network,
      severity: ErrorSeverity.warning,
      title: 'Error de Conexión',
      message: message,
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      context: context,
    );
  }

  static AppError firebase({
    required String message,
    String? technicalDetails,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: _generateId(),
      type: ErrorType.firebase,
      severity: ErrorSeverity.error,
      title: 'Error de Firebase',
      message: message,
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      context: context,
    );
  }

  static AppError authentication({
    required String message,
    String? technicalDetails,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: _generateId(),
      type: ErrorType.authentication,
      severity: ErrorSeverity.error,
      title: 'Error de Autenticación',
      message: message,
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      context: context,
    );
  }

  static AppError validation({
    required String message,
    String? technicalDetails,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: _generateId(),
      type: ErrorType.validation,
      severity: ErrorSeverity.info,
      title: 'Error de Validación',
      message: message,
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      context: context,
    );
  }

  static AppError unknown({
    required String message,
    String? technicalDetails,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: _generateId(),
      type: ErrorType.unknown,
      severity: ErrorSeverity.critical,
      title: 'Error Inesperado',
      message: message,
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      context: context,
    );
  }
}
