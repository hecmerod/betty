import 'dart:convert';
import 'package:http/http.dart' as http;

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
        throw Exception('Server responded with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch protected data: $e');
    }
  }

  Future<bool> registerFCMToken(String fcmToken, String jwtToken) async {
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
      return false;
    }
  }
}
