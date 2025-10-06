import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:typed_data';

class MjpegStreamWidget extends StatefulWidget {
  final String url;
  final Map<String, String> headers;
  final BoxFit fit;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  const MjpegStreamWidget({
    super.key,
    required this.url,
    required this.headers,
    this.fit = BoxFit.contain,
    this.errorWidget,
    this.loadingWidget,
  });

  @override
  State<MjpegStreamWidget> createState() => _MjpegStreamWidgetState();
}

class _MjpegStreamWidgetState extends State<MjpegStreamWidget> {
  Uint8List? _currentFrame;
  bool _isLoading = true;
  String? _error;
  StreamSubscription<Uint8List>? _streamSubscription;
  http.Client? _httpClient;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _startStream();

    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (_isLoading && mounted) {
        _onStreamError('Timeout: No se recibió respuesta del stream en 10 segundos');
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _stopStream();
    super.dispose();
  }

  void _startStream() async {
    // Detener stream anterior si existe
    _stopStream();

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _httpClient = http.Client();

      final request = http.Request('GET', Uri.parse(widget.url));
      widget.headers.forEach((key, value) {
        request.headers[key] = value;
      });

      final response = await _httpClient!.send(request);

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';

        // Permitir tanto multipart/x-mixed-replace como application/octet-stream para MJPEG
        if (contentType.contains('multipart/x-mixed-replace') ||
            contentType.contains('application/octet-stream') ||
            contentType.contains('image/jpeg')) {
          _streamSubscription = _parseMultipartStream(response.stream).listen(
            _onFrameReceived,
            onError: (error) {
              _onStreamError(error);
            },
            onDone: () {
              if (mounted) {
                _onStreamError('Stream ended unexpectedly');
              }
            },
            cancelOnError: false, // No cancelar automáticamente en errores
          );
        } else {
          _onStreamError('Invalid content type: $contentType. Expected multipart/x-mixed-replace or image/jpeg');
        }
      } else {
        _onStreamError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (mounted) {
        _onStreamError('Connection error: $e');
      }
    }
  }

  void _stopStream() {
    _streamSubscription?.cancel();
    _streamSubscription = null;

    if (_httpClient != null) {
      _httpClient!.close();
      _httpClient = null;
    }
  }

  Stream<Uint8List> _parseMultipartStream(Stream<List<int>> stream) async* {
    final buffer = <int>[];

    // JPEG markers - basado en mjpeg_view library
    const int startMarker1 = 0xFF;
    const int startMarker2 = 0xD8; // SOI (Start of Image)
    const int endMarker1 = 0xFF;
    const int endMarker2 = 0xD9; // EOI (End of Image)

    int soiSearchStart = 0;
    int foundSoiIndex = -1;

    await for (final chunk in stream) {
      buffer.addAll(chunk);

      while (true) {
        // Si ya encontramos SOI, buscar EOI
        if (foundSoiIndex != -1) {
          final eoiSearchStart = foundSoiIndex + 2;

          if (buffer.length < eoiSearchStart + 2) {
            break; // No hay suficientes bytes para EOI
          }

          final eoiIndex = _findJpegMarker(buffer, endMarker1, endMarker2, eoiSearchStart);

          if (eoiIndex == -1) {
            break; // EOI no encontrado aún
          } else {
            // Frame completo encontrado
            final frame = buffer.sublist(foundSoiIndex, eoiIndex + 2);

            if (frame.length > 2) {
              yield Uint8List.fromList(frame);
            }

            // Limpiar buffer y resetear búsqueda
            buffer.removeRange(0, eoiIndex + 2);
            soiSearchStart = 0;
            foundSoiIndex = -1;
          }
        } else {
          // Buscar SOI
          if (buffer.length < soiSearchStart + 2) {
            break; // No hay suficientes bytes para SOI
          }

          foundSoiIndex = _findJpegMarker(buffer, startMarker1, startMarker2, soiSearchStart);

          if (foundSoiIndex == -1) {
            // SOI no encontrado, actualizar punto de búsqueda
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
    _timeoutTimer?.cancel(); // Cancelar timeout ya que recibimos data
    if (mounted) {
      setState(() {
        _currentFrame = frameData;
        _isLoading = false;
        _error = null;
      });
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
    if (_error != null) {
      return widget.errorWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text('Error: $_error'),
              ],
            ),
          );
    }

    if (_isLoading || _currentFrame == null) {
      return widget.loadingWidget ??
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(), SizedBox(height: 8), Text('Connecting to video stream...')],
            ),
          );
    }

    return Image.memory(
      _currentFrame!,
      fit: widget.fit,
      gaplessPlayback: true, // Importante para streams continuos
    );
  }
}
