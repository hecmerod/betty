import 'package:flutter/foundation.dart';
import '../../application/usecases/get_photo.dart';
import '../../application/usecases/get_video_stream.dart';
import '../../../shared/error/services/error_service.dart';

class CameraProvider extends ChangeNotifier {
  final GetPhotoUseCase getPhotoUseCase;
  final GetVideoStreamUseCase getVideoStreamUseCase;

  CameraProvider({required this.getPhotoUseCase, required this.getVideoStreamUseCase});

  bool _isLoading = false;
  bool _isVideoActive = false;
  Uint8List? _lastPhoto;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isVideoActive => _isVideoActive;
  Uint8List? get lastPhoto => _lastPhoto;
  String? get error => _error;

  String get videoStreamUrl => getVideoStreamUseCase.getVideoStreamUrl();
  Map<String, String> get videoStreamHeaders => getVideoStreamUseCase.getVideoStreamHeaders();

  Future<void> capturePhoto() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final photo = await getPhotoUseCase.call();
      _lastPhoto = photo;
      notifyListeners();
    } catch (e, stackTrace) {
      final errorMessage = 'No se pudo capturar la foto';
      _setError(errorMessage);
      ErrorService().reportNetworkError(
        message: errorMessage,
        technicalDetails: 'Failed to capture photo: $e',
        stackTrace: stackTrace,
        context: {'useCase': 'capturePhoto'},
      );
    } finally {
      _setLoading(false);
    }
  }

  void startVideo() {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      _isVideoActive = true;
      notifyListeners();
    } catch (e, stackTrace) {
      const errorMessage = 'No se pudo iniciar el video';
      _setError(errorMessage);
      ErrorService().reportNetworkError(
        message: errorMessage,
        technicalDetails: 'Failed to start video: $e',
        stackTrace: stackTrace,
        context: {'useCase': 'startVideo'},
      );
    } finally {
      _setLoading(false);
    }
  }

  void stopVideo() {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      _isVideoActive = false;
      notifyListeners();
    } catch (e, stackTrace) {
      const errorMessage = 'No se pudo detener el video';
      _setError(errorMessage);
      ErrorService().reportNetworkError(
        message: errorMessage,
        technicalDetails: 'Failed to stop video: $e',
        stackTrace: stackTrace,
        context: {'useCase': 'stopVideo'},
      );
    } finally {
      _setLoading(false);
    }
  }

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
