import 'dart:typed_data';
import '../../domain/repositories/camera_repository.dart';

class GetPhotoUseCase {
  final CameraRepository repository;

  const GetPhotoUseCase(this.repository);

  Future<Uint8List> call() async {
    return await repository.capturePhoto();
  }
}
