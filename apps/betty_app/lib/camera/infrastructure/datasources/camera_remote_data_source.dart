import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../shared/server/betty_api_service.dart';
import '../../../shared/jwt/jwt_service.dart';
import '../../../error/error.dart';

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
        ErrorService().reportNetworkError(
          message: 'El servidor de cámara no pudo procesar la solicitud de foto',
          technicalDetails: 'Camera API responded with status ${response.statusCode}',
          context: {'url': '${apiService.baseUrl}/camera/photo', 'statusCode': response.statusCode},
        );
        throw Exception('Server responded with status ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      ErrorService().reportNetworkError(
        message: 'Error de conexión con el servidor de cámara',
        technicalDetails: 'Failed to capture photo from camera API: $e',
        stackTrace: stackTrace,
        context: {'url': '${apiService.baseUrl}/camera/photo'},
      );
      throw Exception('Failed to capture photo: $e');
    }
  }

  @override
  String getVideoStreamUrl() {
    return '${apiService.baseUrl}/camera/video';
  }

  @override
  Map<String, String> getVideoStreamHeaders() {
    return {
      'Authorization': 'Bearer ${JwtService.generateToken()}',
      'Accept': 'image/*,*/*',
      'Cache-Control': 'no-cache',
    };
  }
}
