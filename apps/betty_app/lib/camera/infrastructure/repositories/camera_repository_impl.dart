import 'dart:typed_data';
import '../../domain/repositories/camera_repository.dart';
import '../datasources/camera_remote_data_source.dart';
import '../../../error/error.dart';

class CameraRepositoryImpl implements CameraRepository {
  final CameraRemoteDataSource remoteDataSource;

  const CameraRepositoryImpl(this.remoteDataSource);

  @override
  Future<Uint8List> capturePhoto() async {
    try {
      return await remoteDataSource.capturePhoto();
    } catch (e, stackTrace) {
      ErrorService().reportNetworkError(
        message: 'Error al capturar foto desde el servidor de cámara',
        technicalDetails: 'CameraRepository failed to capture photo: $e',
        stackTrace: stackTrace,
        context: {'repository': 'CameraRepositoryImpl'},
      );
      throw Exception('Failed to capture photo: $e');
    }
  }

  @override
  String getVideoStreamUrl() {
    return remoteDataSource.getVideoStreamUrl();
  }

  @override
  Map<String, String> getVideoStreamHeaders() {
    return remoteDataSource.getVideoStreamHeaders();
  }
}
