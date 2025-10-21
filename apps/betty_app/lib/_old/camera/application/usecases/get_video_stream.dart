import '../../domain/repositories/camera_repository.dart';

class GetVideoStreamUseCase {
  final CameraRepository repository;

  const GetVideoStreamUseCase(this.repository);

  String getVideoStreamUrl() {
    return repository.getVideoStreamUrl();
  }

  Map<String, String> getVideoStreamHeaders() {
    return repository.getVideoStreamHeaders();
  }
}
