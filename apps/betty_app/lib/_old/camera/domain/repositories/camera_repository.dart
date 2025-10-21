import 'dart:typed_data';

abstract class CameraRepository {
  Future<Uint8List> capturePhoto();
  String getVideoStreamUrl();
  Map<String, String> getVideoStreamHeaders();
}
