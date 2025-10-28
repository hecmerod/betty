import 'package:flutter/material.dart';
import 'dart:typed_data';

class VideoDisplayWidget extends StatelessWidget {
  final ValueNotifier<Uint8List?> frameNotifier;
  final bool roundedCorners;

  const VideoDisplayWidget({super.key, required this.frameNotifier, this.roundedCorners = true});

  @override
  Widget build(BuildContext context) {
    final content = SizedBox.expand(
      child: Container(
        color: Colors.grey[900],
        child: ValueListenableBuilder<Uint8List?>(
          valueListenable: frameNotifier,
          builder: (context, frameData, child) {
            if (frameData == null) {
              return const SizedBox.shrink();
            }
            return Image.memory(frameData, fit: BoxFit.contain, gaplessPlayback: true);
          },
        ),
      ),
    );

    if (!roundedCorners) {
      return content;
    }

    return ClipRRect(key: const ValueKey('video'), borderRadius: BorderRadius.circular(16), child: content);
  }
}
