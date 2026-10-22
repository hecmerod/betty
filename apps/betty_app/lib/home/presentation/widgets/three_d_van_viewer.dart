import 'package:betty_app/home/infrastructure/home_config.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ThreeDVanViewer extends StatefulWidget {
  final bool isActive;

  const ThreeDVanViewer({super.key, this.isActive = true});

  @override
  State<ThreeDVanViewer> createState() => _ThreeDVanViewerState();
}

class _ThreeDVanViewerState extends State<ThreeDVanViewer> {
  WebViewController? _webViewController;

  @override
  void didUpdateWidget(covariant ThreeDVanViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) _syncAutoRotate();
  }

  void _syncAutoRotate() {
    _webViewController
        ?.runJavaScript("document.querySelector('model-viewer')?.toggleAttribute('auto-rotate', ${widget.isActive});")
        .catchError((_) {});
  }

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

      onWebViewCreated: (controller) => _webViewController = controller,
    );
  }
}
