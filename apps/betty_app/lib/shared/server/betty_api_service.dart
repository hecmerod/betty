import 'dart:convert';
import 'package:http/http.dart' as http;
import '../jwt/jwt_service.dart';

class BettyApiService {
  final String baseUrl;
  final Duration timeout;

  const BettyApiService({required this.baseUrl, this.timeout = const Duration(seconds: 5)});

  Map<String, String> get _defaultHeaders => {
    'Authorization': 'Bearer ${JwtService.generateToken()}',
    'Content-Type': 'application/json',
  };

  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(uri, headers: {..._defaultHeaders, ...?headers}).timeout(timeout);

    return response;
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .post(uri, headers: {..._defaultHeaders, ...?headers}, body: body != null ? json.encode(body) : null)
        .timeout(timeout);

    return response;
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .put(uri, headers: {..._defaultHeaders, ...?headers}, body: body != null ? json.encode(body) : null)
        .timeout(timeout);

    return response;
  }

  Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .patch(uri, headers: {..._defaultHeaders, ...?headers}, body: body != null ? json.encode(body) : null)
        .timeout(timeout);

    return response;
  }

  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(uri, headers: {..._defaultHeaders, ...?headers}).timeout(timeout);

    return response;
  }
}
