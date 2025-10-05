import 'package:flutter/foundation.dart';
import '../../application/usecases/get_photo.dart';
import '../../application/usecases/get_video_stream.dart';

class CameraProvider extends ChangeNotifier {
  final GetPhotoUseCase getPhotoUseCase;
  final GetVideoStreamUseCase getVideoStreamUseCase;

  CameraProvider({required this.getPhotoUseCase, required this.getVideoStreamUseCase});

  // Estado
  bool _isLoading = false;
  bool _isVideoActive = false;
  Uint8List? _lastPhoto;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  bool get isVideoActive => _isVideoActive;
  Uint8List? get lastPhoto => _lastPhoto;
  String? get error => _error;

  String get videoStreamUrl => getVideoStreamUseCase.getVideoStreamUrl();
  Map<String, String> get videoStreamHeaders => getVideoStreamUseCase.getVideoStreamHeaders();

  // Capturar foto
  Future<void> capturePhoto() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final photo = await getPhotoUseCase.call();
      _lastPhoto = photo;
      notifyListeners();
    } catch (e) {
      _setError('Failed to capture photo: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Iniciar video stream
  void startVideo() {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      _isVideoActive = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to start video: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Detener video stream
  void stopVideo() {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      _isVideoActive = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to stop video: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Métodos privados de utilidad
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
