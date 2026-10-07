import 'package:betty_app/camera/infrastructure/camera_service.dart';
import 'package:betty_app/camera/presentation/widgets/video_stream_widget.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VideoStreamWidget(cameraType: CameraType.internal);
  }
}
