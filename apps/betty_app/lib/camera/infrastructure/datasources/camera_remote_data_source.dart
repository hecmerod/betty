import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../shared/infrastructure/services/betty_api_service.dart';
import '../../../auth/infrastructure/services/jwt_service.dart';

abstract class CameraRemoteDataSource {
  Future<Uint8List> capturePhoto();
  String getVideoStreamUrl();
  Map<String, String> getVideoStreamHeaders();
}

class CameraRemoteDataSourceImpl implements CameraRemoteDataSource {
  final BettyApiService apiService;

  const CameraRemoteDataSourceImpl(this.apiService);

  @override
  Future<Uint8List> capturePhoto() async {
    try {
      final response = await http.get(
        Uri.parse('${apiService.baseUrl}/camera/photo'),
        headers: {'Authorization': 'Bearer ${JwtService.generateToken()}', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Server responded with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to capture photo: $e');
    }
  }

  @override
  String getVideoStreamUrl() {
    // Intentamos con headers de autorización en lugar de query param
    return '${apiService.baseUrl}/camera/video';
  }

  @override
  Map<String, String> getVideoStreamHeaders() {
    // Incluir el JWT token en los headers para autenticación
    return {
      'Authorization': 'Bearer ${JwtService.generateToken()}',
      'Accept': 'image/*,*/*',
      'Cache-Control': 'no-cache',
    };
  }
}
