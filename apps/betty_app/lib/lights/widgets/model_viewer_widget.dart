import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewerWidget extends StatelessWidget {
  final String modelSrc;

  const ModelViewerWidget({super.key, required this.modelSrc});

  @override
  Widget build(BuildContext context) {
    return ModelViewer(
      key: ValueKey(modelSrc),
      src: modelSrc,
      alt: 'Modelo 3D de la furgoneta',
      disableZoom: true,
      disablePan: true,
      backgroundColor: Colors.transparent,
      shadowIntensity: 1.0,
      cameraOrbit: '325deg 75deg 105%',
      cameraTarget: '0m 3m 0m',
      fieldOfView: '90deg',
      minCameraOrbit: 'auto 75deg 105%',
      maxCameraOrbit: 'auto 75deg 105%',
      touchAction: TouchAction.panY,
    );
  }
}
