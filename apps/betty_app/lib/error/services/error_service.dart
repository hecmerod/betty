import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../domain/models/app_error.dart';
import '../domain/models/app_error_factory.dart';
import '../presentation/dialogs/error_dialog.dart';

class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  final StreamController<AppError> _errorController = StreamController<AppError>.broadcast();

  Stream<AppError> get errorStream => _errorController.stream;

  GlobalKey<NavigatorState>? _navigatorKey;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _setupGlobalErrorHandlers();
  }

  void _setupGlobalErrorHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final error = AppErrorFactory.unknown(
        message: 'Error en el renderizado de la interfaz',
        technicalDetails: details.exceptionAsString(),
        stackTrace: details.stack,
        context: {'library': details.library, 'context': details.context?.toString()},
      );
      reportError(error);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      final appError = AppErrorFactory.unknown(
        message: 'Error no capturado en la aplicación',
        technicalDetails: error.toString(),
        stackTrace: stack,
      );
      reportError(appError);
      return true;
    };
  }

  void reportError(AppError error) {
    if (error.shouldLog) {
      _logError(error);
    }

    _errorController.add(error);

    if (error.shouldShowToUser) {
      _showErrorToUser(error);
    }
  }

  void reportNetworkError({
    required String message,
    String? technicalDetails,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final error = AppErrorFactory.network(
      message: message,
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      context: context,
    );
    reportError(error);
  }

  void reportFirebaseError({
    required String message,
    String? technicalDetails,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final error = AppErrorFactory.firebase(
      message: message,
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      context: context,
    );
    reportError(error);
  }

  void reportAuthenticationError({
    required String message,
    String? technicalDetails,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final error = AppErrorFactory.authentication(
      message: message,
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      context: context,
    );
    reportError(error);
  }

  void reportValidationError({
    required String message,
    String? technicalDetails,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final error = AppErrorFactory.validation(
      message: message,
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      context: context,
    );
    reportError(error);
  }

  void reportUnknownError({
    required dynamic exception,
    StackTrace? stackTrace,
    String? customMessage,
    Map<String, dynamic>? context,
  }) {
    final error = AppErrorFactory.unknown(
      message: customMessage ?? 'Ha ocurrido un error inesperado',
      technicalDetails: exception.toString(),
      stackTrace: stackTrace,
      context: context,
    );
    reportError(error);
  }

  void _showErrorToUser(AppError error) {
    final context = _navigatorKey?.currentContext;
    if (context != null) {
      Timer(Duration.zero, () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ErrorDialog(error: error),
        );
      });
    }
  }

  void _logError(AppError error) {
    if (kDebugMode) {
      developer.log(error.message, name: 'ErrorService', error: error.technicalDetails, stackTrace: error.stackTrace);
    }
  }

  void dispose() {
    _errorController.close();
  }
}
