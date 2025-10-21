import 'dart:convert';
import 'package:http/http.dart' as http;
import 'jwt_service.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._();

  final _jwtService = JwtService.instance;
  final _config = AppConfig.instance;
  final Duration timeout = const Duration(seconds: 10);

  String get baseUrl => _config.bettyApiBaseUrl;

  Map<String, String> get _defaultHeaders => {
    'Authorization': 'Bearer ${_jwtService.generateToken()}',
    'Content-Type': 'application/json',
  };

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    var uri = Uri.parse('$baseUrl$endpoint');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

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

  Future<T> getJson<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await get(endpoint, headers: headers, queryParameters: queryParameters);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      return fromJson(data);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Error en la petición GET $endpoint',
        body: response.body,
      );
    }
  }

  Future<T> postJson<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await post(endpoint, body: body, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      return fromJson(data);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Error en la petición POST $endpoint',
        body: response.body,
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String body;

  ApiException({required this.statusCode, required this.message, required this.body});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
