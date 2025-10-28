import 'package:flutter/material.dart';
import '../services/camera_service.dart';
import '../widgets/video_stream_widget.dart';
import '../widgets/capture_button_widget.dart';

class InternalCameraPage extends StatelessWidget {
  const InternalCameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Hero(
              tag: 'camera-internal-hero',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(16)),
                  child: const VideoStreamWidget(
                    cameraType: CameraType.internal,
                    enableFullscreen: true,
                    heroTag: 'camera-internal-hero',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const CaptureButtonWidget(cameraType: CameraType.internal),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
