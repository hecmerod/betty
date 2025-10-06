import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../error/error.dart';

class BettyApiService {
  final String baseUrl;
  final Duration timeout;

  const BettyApiService({required this.baseUrl, this.timeout = const Duration(seconds: 5)});

  Future<Map<String, dynamic>> fetchProtectedData(String jwtToken) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/protected'),
            headers: {'Authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        ErrorService().reportNetworkError(
          message: 'Error del servidor al obtener datos protegidos',
          technicalDetails: 'Server responded with status ${response.statusCode}',
          context: {'url': '$baseUrl/protected', 'statusCode': response.statusCode},
        );
        throw Exception('Server responded with status ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      ErrorService().reportNetworkError(
        message: 'No se pudieron obtener los datos del servidor',
        technicalDetails: 'Failed to fetch protected data: $e',
        stackTrace: stackTrace,
        context: {'url': '$baseUrl/protected'},
      );
      rethrow;
    }
  }

  Future<bool> registerFCMToken(String fcmToken, String jwtToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/notifications/register'),
            headers: {'Authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json'},
            body: json.encode({'token': fcmToken, 'userId': 'betty-user', 'platform': 'mobile'}),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        ErrorService().reportNetworkError(
          message: 'El servidor no pudo registrar el token de notificaciones',
          technicalDetails: 'Server responded with status ${response.statusCode}',
          context: {'url': '$baseUrl/notifications/register', 'statusCode': response.statusCode, 'fcmToken': fcmToken},
        );
        return false;
      }
    } catch (e, stackTrace) {
      ErrorService().reportNetworkError(
        message: 'Error de conexión al registrar token de notificaciones',
        technicalDetails: 'Failed to register FCM token: $e',
        stackTrace: stackTrace,
        context: {'url': '$baseUrl/notifications/register', 'fcmToken': fcmToken},
      );
      return false;
    }
  }
}
