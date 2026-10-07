import 'package:betty_app/home/infrastructure/home_config.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ThreeDVanViewer extends StatelessWidget {
  const ThreeDVanViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final String modelSrc = HomeConfig.instance.threeDVanModel;

    return ModelViewer(
      key: ValueKey(modelSrc),
      src: modelSrc,

      disableZoom: true,
      disablePan: true,
      disableTap: true,
      cameraControls: false,

      fieldOfView: '120deg',
      cameraOrbit: '150deg 65deg 20%',
      cameraTarget: '0m 3m 0m',

      autoRotate: true,
      autoRotateDelay: 0,
      rotationPerSecond: '0.8deg',
    );
  }
}
