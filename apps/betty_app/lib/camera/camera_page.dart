import 'package:flutter/material.dart';
import 'widgets/video_stream_widget.dart';
import 'widgets/capture_button_widget.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.transparent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Expanded(
                  child: Hero(
                    tag: 'camera-hero',
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(16)),
                        child: const VideoStreamWidget(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const CaptureButtonWidget(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
