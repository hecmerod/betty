import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'widgets/video_display_widget.dart';

class CameraFullscreenPage extends StatelessWidget {
  final ValueListenable<ui.Image?> imageNotifier;
  final Animation<double> animation;
  final Rect sourceRect;

  const CameraFullscreenPage({
    super.key,
    required this.imageNotifier,
    required this.animation,
    required this.sourceRect,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = Curves.easeInOutCubic.transform(animation.value);
        final width = ui.lerpDouble(sourceRect.width, size.height, t)!;
        final height = ui.lerpDouble(sourceRect.height, size.width, t)!;
        final left = ui.lerpDouble(
          sourceRect.left,
          (size.width - width) / 2,
          t,
        )!;
        final top = ui.lerpDouble(
          sourceRect.top,
          (size.height - height) / 2,
          t,
        )!;
        final closeOpacity = const Interval(0.75, 1).transform(t);

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: left,
                top: top,
                width: width,
                height: height,
                child: Transform.rotate(
                  angle: t * math.pi / 2,
                  child: VideoDisplayWidget(
                    imageNotifier: imageNotifier,
                    roundedCorners: t < 0.95,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: IgnorePointer(
                  ignoring: closeOpacity < 0.5,
                  child: Opacity(
                    opacity: closeOpacity,
                    child: SafeArea(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
