import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

class MjpegStreamException implements Exception {
  final String message;

  const MjpegStreamException(this.message);

  @override
  String toString() => message;
}

/// Reads an MJPEG stream in a background isolate and emits complete JPEG frames.
class MjpegStreamClient {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  StreamController<Uint8List>? _controller;

  Stream<Uint8List> start({required String url, required Map<String, String> headers}) {
    stop();

    final controller = StreamController<Uint8List>();
    final receivePort = ReceivePort();
    _controller = controller;
    _receivePort = receivePort;

    receivePort.listen((message) {
      if (message is TransferableTypedData) {
        controller.add(message.materialize().asUint8List());
      } else if (message is String) {
        controller.addError(MjpegStreamException(message));
      } else if (message == null) {
        controller.close();
      }
    });

    Isolate.spawn(_run, _StreamRequest(receivePort.sendPort, url, headers)).then(
      (isolate) {
        if (identical(_receivePort, receivePort)) {
          _isolate = isolate;
        } else {
          isolate.kill(priority: Isolate.immediate);
        }
      },
      onError: (Object error) {
        if (!controller.isClosed) controller.addError(MjpegStreamException('$error'));
      },
    );

    return controller.stream;
  }

  void stop() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    _controller?.close();
    _controller = null;
  }
}

class _StreamRequest {
  final SendPort sendPort;
  final String url;
  final Map<String, String> headers;

  const _StreamRequest(this.sendPort, this.url, this.headers);
}

Future<void> _run(_StreamRequest request) async {
  final sendPort = request.sendPort;
  final client = HttpClient();

  try {
    final httpRequest = await client.getUrl(Uri.parse(request.url));
    request.headers.forEach(httpRequest.headers.set);
    final response = await httpRequest.close();

    if (response.statusCode != HttpStatus.ok) {
      sendPort.send('HTTP ${response.statusCode}');
      return;
    }

    final parser = _JpegFrameParser();
    await for (final chunk in response) {
      parser.add(chunk, (frame) => sendPort.send(TransferableTypedData.fromList([frame])));
    }
    sendPort.send(null);
  } catch (e) {
    sendPort.send('Error de conexión: $e');
  } finally {
    client.close(force: true);
  }
}

class _JpegFrameParser {
  static const int _marker = 0xFF;
  static const int _soi = 0xD8;
  static const int _eoi = 0xD9;

  Uint8List _buffer = Uint8List(256 * 1024);
  int _length = 0;
  int _scanFrom = 0;
  int _frameStart = -1;

  void add(List<int> chunk, void Function(Uint8List frame) onFrame) {
    _append(chunk);

    while (true) {
      if (_frameStart == -1) {
        final start = _find(_soi, _scanFrom);
        if (start == -1) {
          _discardAllButLastByte();
          return;
        }
        _frameStart = start;
        _scanFrom = start + 2;
      }

      final end = _find(_eoi, _scanFrom);
      if (end == -1) {
        _scanFrom = _length > _scanFrom ? _length - 1 : _scanFrom;
        return;
      }

      onFrame(Uint8List.sublistView(_buffer, _frameStart, end + 2));
      _consume(end + 2);
    }
  }

  void _append(List<int> chunk) {
    final required = _length + chunk.length;
    if (required > _buffer.length) {
      var capacity = _buffer.length * 2;
      while (capacity < required) {
        capacity *= 2;
      }
      _buffer = Uint8List(capacity)..setRange(0, _length, _buffer);
    }
    _buffer.setRange(_length, required, chunk);
    _length = required;
  }

  int _find(int second, int from) {
    for (var i = from; i < _length - 1; i++) {
      if (_buffer[i] == _marker && _buffer[i + 1] == second) return i;
    }
    return -1;
  }

  void _consume(int count) {
    _buffer.setRange(0, _length - count, _buffer, count);
    _length -= count;
    _scanFrom = 0;
    _frameStart = -1;
  }

  void _discardAllButLastByte() {
    if (_length > 1) _consume(_length - 1);
    _scanFrom = 0;
  }
}
