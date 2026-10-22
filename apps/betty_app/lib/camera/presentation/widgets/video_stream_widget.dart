import 'package:betty_app/camera/infrastructure/camera_service.dart';
import 'package:betty_app/camera/infrastructure/mjpeg_stream_client.dart';
import 'package:betty_app/camera/presentation/camera_fullscreen_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'video_error_widget.dart';
import 'video_loading_widget.dart';
import 'video_display_widget.dart';

class VideoStreamWidget extends StatefulWidget {
  final CameraType cameraType;
  final bool enableFullscreen;
  final String heroTag;
  final int? cameraIndex;
  final bool grid;
  final bool isActive;

  const VideoStreamWidget({
    super.key,
    required this.cameraType,
    this.enableFullscreen = false,
    this.heroTag = 'camera-video',
    this.cameraIndex,
    this.grid = false,
    this.isActive = true,
  });

  @override
  State<VideoStreamWidget> createState() => _VideoStreamWidgetState();
}

class _VideoStreamWidgetState extends State<VideoStreamWidget> {
  final _cameraService = CameraService.instance;
  final _streamClient = MjpegStreamClient();
  final _imageNotifier = ValueNotifier<ui.Image?>(null);
  bool _isLoading = true;
  String? _error;
  StreamSubscription<Uint8List>? _streamSubscription;
  bool _isDecoding = false;
  Uint8List? _pendingFrame;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _startStream();
  }

  @override
  void didUpdateWidget(covariant VideoStreamWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;
    widget.isActive ? _startStream() : _stopStream();
  }

  @override
  void dispose() {
    _stopStream();
    _imageNotifier.value?.dispose();
    _imageNotifier.dispose();
    super.dispose();
  }

  void _startStream() {
    _stopStream();

    final url = _cameraService.getVideoStreamUrl(
      type: widget.cameraType,
      index: widget.cameraIndex,
      grid: widget.grid,
    );

    _streamSubscription = _streamClient
        .start(url: url, headers: _cameraService.getVideoStreamHeaders())
        .listen(
          _onFrameReceived,
          onError: _onStreamError,
          onDone: () => _onStreamError('Stream finalizado'),
          cancelOnError: false,
        );
  }

  void _stopStream() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _streamClient.stop();
    _pendingFrame = null;
  }

  void _onFrameReceived(Uint8List frameData) {
    if (_isDecoding) {
      _pendingFrame = frameData;
      return;
    }
    _decodeFrame(frameData);
  }

  Future<void> _decodeFrame(Uint8List frameData) async {
    _isDecoding = true;
    ui.Image? image;
    try {
      final codec = await ui.instantiateImageCodec(frameData);
      final frame = await codec.getNextFrame();
      codec.dispose();
      image = frame.image;
    } catch (_) {
      // Skip corrupt frames.
    }
    _isDecoding = false;

    if (!mounted) {
      image?.dispose();
      return;
    }

    if (image != null) _showImage(image);

    final pending = _pendingFrame;
    _pendingFrame = null;
    if (pending != null && _streamSubscription != null) _decodeFrame(pending);
  }

  void _showImage(ui.Image image) {
    final previous = _imageNotifier.value;
    _imageNotifier.value = image;
    previous?.dispose();

    if (_isLoading || _error != null) {
      setState(() {
        _isLoading = false;
        _error = null;
      });
    }
  }

  void _onStreamError(Object error) {
    if (!mounted) return;
    setState(() {
      _error = error.toString();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: child.key == const ValueKey('video') ? 1.0 : 0.2,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
          child: child,
        );
      },
      child: _buildContent(context),
    );

    if (!widget.enableFullscreen) {
      return content;
    }

    return GestureDetector(
      onTap: () {
        if (_error == null && !_isLoading) {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, animation, secondaryAnimation) {
                return FadeTransition(opacity: animation, child: _buildFullscreenPage(context));
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
      },
      child: content,
    );
  }

  Widget _buildFullscreenPage(BuildContext context) {
    return CameraFullscreenPage(imageNotifier: _imageNotifier, heroTag: widget.heroTag);
  }

  Widget _buildContent(BuildContext context) {
    if (_error != null) {
      return VideoErrorWidget(error: _error!);
    }

    if (_isLoading || _imageNotifier.value == null) {
      return const VideoLoadingWidget();
    }

    return VideoDisplayWidget(imageNotifier: _imageNotifier);
  }
}
