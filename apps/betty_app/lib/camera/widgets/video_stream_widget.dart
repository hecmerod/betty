import 'package:betty_app/camera/services/camera_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:typed_data';
import 'video_error_widget.dart';
import 'video_loading_widget.dart';
import 'video_display_widget.dart';

class VideoStreamWidget extends StatefulWidget {
  const VideoStreamWidget({super.key});

  @override
  State<VideoStreamWidget> createState() => _VideoStreamWidgetState();
}

class _VideoStreamWidgetState extends State<VideoStreamWidget> {
  final _cameraService = CameraService.instance;
  final _frameNotifier = ValueNotifier<Uint8List?>(null);
  bool _isLoading = true;
  String? _error;
  StreamSubscription<Uint8List>? _streamSubscription;
  http.Client? _httpClient;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _frameNotifier.dispose();
    _stopStream();
    super.dispose();
  }

  void _startStream() async {
    try {
      final url = _cameraService.getVideoStreamUrl();
      _httpClient = http.Client();
      final request = http.Request('GET', Uri.parse(url));

      final headers = _cameraService.getVideoStreamHeaders();

      headers.forEach((key, value) {
        request.headers[key] = value;
      });

      final response = await _httpClient!.send(request);

      if (response.statusCode == 200) {
        _streamSubscription = _parseMultipartStream(response.stream).listen(
          _onFrameReceived,
          onError: _onStreamError,
          onDone: () {
            if (mounted) {
              _onStreamError('Stream finalizado');
            }
          },
          cancelOnError: false,
        );
      } else {
        _onStreamError('HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        _onStreamError('Error de conexión: $e');
      }
    }
  }

  Future<void> _stopStream() async {
    // Primero cancelar la suscripción
    try {
      await _streamSubscription?.cancel();
    } catch (e) {
      // Ignorar errores
    } finally {
      _streamSubscription = null;
    }

    // Esperar un poco antes de cerrar el cliente para que termine de procesar
    await Future.delayed(const Duration(milliseconds: 100));

    // Ahora cerrar el cliente HTTP
    try {
      _httpClient?.close();
    } catch (e) {
      // Ignorar errores
    } finally {
      _httpClient = null;
    }
  }

  Stream<Uint8List> _parseMultipartStream(Stream<List<int>> stream) async* {
    final buffer = <int>[];
    const int startMarker1 = 0xFF;
    const int startMarker2 = 0xD8;
    const int endMarker1 = 0xFF;
    const int endMarker2 = 0xD9;

    int soiSearchStart = 0;
    int foundSoiIndex = -1;

    await for (final chunk in stream) {
      buffer.addAll(chunk);

      while (true) {
        if (foundSoiIndex != -1) {
          final eoiSearchStart = foundSoiIndex + 2;
          if (buffer.length < eoiSearchStart + 2) break;

          final eoiIndex = _findJpegMarker(buffer, endMarker1, endMarker2, eoiSearchStart);
          if (eoiIndex == -1) {
            break;
          } else {
            final frame = buffer.sublist(foundSoiIndex, eoiIndex + 2);
            if (frame.length > 2) {
              yield Uint8List.fromList(frame);
            }
            buffer.removeRange(0, eoiIndex + 2);
            soiSearchStart = 0;
            foundSoiIndex = -1;
          }
        } else {
          if (buffer.length < soiSearchStart + 2) break;
          foundSoiIndex = _findJpegMarker(buffer, startMarker1, startMarker2, soiSearchStart);
          if (foundSoiIndex == -1) {
            soiSearchStart = buffer.length > 1 ? buffer.length - 1 : 0;
            break;
          }
        }
      }
    }
  }

  int _findJpegMarker(List<int> buffer, int marker1, int marker2, int startIndex) {
    if (buffer.length < startIndex + 2) return -1;
    for (int i = startIndex; i <= buffer.length - 2; i++) {
      if (buffer[i] == marker1 && buffer[i + 1] == marker2) {
        return i;
      }
    }
    return -1;
  }

  void _onFrameReceived(Uint8List frameData) {
    _timeoutTimer?.cancel();
    if (mounted) {
      final bool wasLoading = _isLoading;
      _frameNotifier.value = frameData;

      if (wasLoading || _error != null) {
        setState(() {
          _isLoading = false;
          _error = null;
        });
      }
    }
  }

  void _onStreamError(dynamic error) {
    _timeoutTimer?.cancel();
    if (mounted) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: child.key == const ValueKey('video') ? 2.0 : 0.2,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
          child: child,
        );
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_error != null) {
      return VideoErrorWidget(error: _error!);
    }

    if (_isLoading || _frameNotifier.value == null) {
      return const VideoLoadingWidget();
    }

    return VideoDisplayWidget(frameNotifier: _frameNotifier);
  }
}
