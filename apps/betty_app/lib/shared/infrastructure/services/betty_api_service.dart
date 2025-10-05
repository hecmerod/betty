import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../health/infrastructure/models/health_data_model.dart';

class BettyApiService {
  final String baseUrl;
  final Duration timeout;

  const BettyApiService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 5),
  });

  Future<HealthDataModel> fetchHealthData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return HealthDataModel.fromJson(data);
      } else {
        throw Exception('Server responded with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch health data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchProtectedData(String jwtToken) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/protected'),
            headers: {
              'Authorization': 'Bearer $jwtToken',
              'Content-Type': 'application/json',
            },
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
}
