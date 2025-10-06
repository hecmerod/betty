import 'dart:convert';
import '../../../shared/server/betty_api_service.dart';
import '../../../error/error.dart';

class NotificationApiService {
  final BettyApiService _apiService;

  const NotificationApiService(this._apiService);

  Future<bool> sendDeviceToken(String fcmToken) async {
    try {
      final response = await _apiService.post(
        '/notifications/register',
        body: {'token': fcmToken, 'userId': 'betty-user', 'platform': 'mobile'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        ErrorService().reportNetworkError(
          message: 'El servidor no pudo registrar el token de notificaciones',
          technicalDetails: 'Server responded with status ${response.statusCode}',
          context: {'endpoint': '/notifications/register', 'statusCode': response.statusCode, 'fcmToken': fcmToken},
        );
        return false;
      }
    } catch (e, stackTrace) {
      ErrorService().reportNetworkError(
        message: 'Error de conexión al registrar token de notificaciones',
        technicalDetails: 'Failed to register FCM token: $e',
        stackTrace: stackTrace,
        context: {'endpoint': '/notifications/register', 'fcmToken': fcmToken},
      );
      return false;
    }
  }
}
