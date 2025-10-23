import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lights_bloc.dart';
import '../bloc/lights_event.dart';
import '../bloc/lights_state.dart';
import 'light_control_button.dart';
import 'model_viewer_widget.dart';

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

class InteriorLightsPage extends StatefulWidget {
  const InteriorLightsPage({super.key});

  @override
  State<InteriorLightsPage> createState() => _InteriorLightsPageState();
}

class _InteriorLightsPageState extends State<InteriorLightsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LightsBloc, LightsState>(
      builder: (context, state) {
        const currentModel = 'assets/models/van.glb';

        return Stack(
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
                      duration: const Duration(milliseconds: 800),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      child: ModelViewerWidget(key: const ValueKey('interior-model'), modelSrc: currentModel),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LightControlButton(
                            icon: Icons.light_mode_rounded,
                            label: 'Techo',
                            isOn: state.ceilingLightsOn,
                            onToggle: (value) {
                              context.read<LightsBloc>().add(ToggleInteriorLightEvent('ceiling', value));
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: LightControlButton(
                            icon: Icons.menu_book_rounded,
                            label: 'Lectura',
                            isOn: state.readingLightsOn,
                            onToggle: (value) {
                              context.read<LightsBloc>().add(ToggleInteriorLightEvent('reading', value));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: LightControlButton(
                            icon: Icons.gradient_rounded,
                            label: 'Ambiente',
                            isOn: state.ambientLightsOn,
                            onToggle: (value) {
                              context.read<LightsBloc>().add(ToggleInteriorLightEvent('ambient', value));
                            },
                            color: const Color(0xFF667eea),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: LightControlButton(
                            icon: Icons.build_rounded,
                            label: 'Trabajo',
                            isOn: state.workLightsOn,
                            onToggle: (value) {
                              context.read<LightsBloc>().add(ToggleInteriorLightEvent('work', value));
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
