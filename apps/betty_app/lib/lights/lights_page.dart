import 'package:flutter/material.dart';
import '../shared/widgets/secondary_page_app_bar.dart';
import 'widgets/light_control_button.dart';
import 'widgets/model_viewer_widget.dart';

class TopCropClipper extends CustomClipper<Rect> {
  final double cropAmount;

  TopCropClipper({required this.cropAmount});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, cropAmount, size.width, size.height);
  }

  @override
  bool shouldReclip(TopCropClipper oldClipper) {
    return oldClipper.cropAmount != cropAmount;
  }
}

class LightsPage extends StatefulWidget {
  const LightsPage({super.key});

  @override
  State<LightsPage> createState() => _LightsPageState();
}

class _LightsPageState extends State<LightsPage> with SingleTickerProviderStateMixin {
  bool _headlightsOn = false;
  bool _interiorLightsOn = false;
  bool _emergencyLightsOn = false;
  bool _fogLightsOn = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _currentModel = 'assets/models/van.glb';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Iniciar animación después de un pequeño delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const SecondaryPageAppBar(title: 'Control de Luces', backgroundOpacity: 0.0),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(scale: _scaleAnimation, child: child),
                  );
                },
                child: SizedBox(
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  child: ClipRect(
                    clipper: TopCropClipper(cropAmount: 20),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      child: ModelViewerWidget(modelSrc: _currentModel),
                    ),
                  ),
                ),
              ),
            ),

            // Panel de controles de luces - Superpuestos en la parte inferior
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LightControlButton(
                            icon: Icons.lightbulb_rounded,
                            label: 'Faros',
                            isOn: _headlightsOn,
                            onToggle: (value) {
                              setState(() {
                                _headlightsOn = value;
                                _currentModel = value ? 'assets/models/van-front-lights.glb' : 'assets/models/van.glb';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: LightControlButton(
                            icon: Icons.light_mode_rounded,
                            label: 'Interior',
                            isOn: _interiorLightsOn,
                            onToggle: (value) => setState(() => _interiorLightsOn = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: LightControlButton(
                            icon: Icons.warning_rounded,
                            label: 'Emergencia',
                            isOn: _emergencyLightsOn,
                            onToggle: (value) => setState(() => _emergencyLightsOn = value),
                            color: const Color(0xFFfa709a),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: LightControlButton(
                            icon: Icons.cloud_rounded,
                            label: 'Antiniebla',
                            isOn: _fogLightsOn,
                            onToggle: (value) => setState(() => _fogLightsOn = value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
