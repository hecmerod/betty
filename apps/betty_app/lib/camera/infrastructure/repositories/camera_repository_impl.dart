import 'dart:typed_data';
import '../../domain/repositories/camera_repository.dart';
import '../datasources/camera_remote_data_source.dart';

class CameraRepositoryImpl implements CameraRepository {
  final CameraRemoteDataSource remoteDataSource;

  const CameraRepositoryImpl(this.remoteDataSource);

  @override
  Future<Uint8List> capturePhoto() async {
    try {
      return await remoteDataSource.capturePhoto();
    } catch (e) {
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
