import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class VideoDisplayWidget extends StatelessWidget {
  final ValueListenable<ui.Image?> imageNotifier;
  final bool roundedCorners;

  const VideoDisplayWidget({super.key, required this.imageNotifier, this.roundedCorners = true});

  @override
  Widget build(BuildContext context) {
    final content = SizedBox.expand(
      child: Container(
        color: Colors.grey[900],
        child: RepaintBoundary(
          child: ValueListenableBuilder<ui.Image?>(
            valueListenable: imageNotifier,
            builder: (context, image, child) {
              if (image == null) {
                return const SizedBox.shrink();
              }
              return RawImage(image: image, fit: BoxFit.contain);
            },
          ),
        ),
      ),
    );

    if (!roundedCorners) {
      return content;
    }

    return ClipRRect(key: const ValueKey('video'), borderRadius: BorderRadius.circular(16), child: content);
  }
}
