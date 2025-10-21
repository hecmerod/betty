import 'package:flutter/material.dart';
import '../services/camera_service.dart';

class CaptureButtonWidget extends StatefulWidget {
  const CaptureButtonWidget({super.key});

  @override
  State<CaptureButtonWidget> createState() => _CaptureButtonWidgetState();
}

class _CaptureButtonWidgetState extends State<CaptureButtonWidget> {
  final _cameraService = CameraService.instance;
  bool _isCapturing = false;

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      await _cameraService.capturePhoto();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto capturada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al capturar foto: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: _isCapturing ? null : _capturePhoto,
      backgroundColor: Colors.white,
      child: _isCapturing
          ? const CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.black))
          : const Icon(Icons.camera_alt, size: 36, color: Colors.black),
    );
  }
}
