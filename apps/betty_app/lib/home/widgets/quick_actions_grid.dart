import 'package:betty_app/shared/navigation/animations/visibility_animation.dart';
import 'package:betty_app/shared/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/navigation/bloc/navigation_bloc.dart';
import '../../shared/navigation/bloc/navigation_event.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        VisibilityAnimation(
          animationId: 'camera_button',
          child: QuickActionCard(
            icon: Icons.videocam_rounded,
            title: 'Cámara',
            onTap: () {
              context.read<NavigationBloc>().add(
                const NavigateToPage(Routes.camera, excludeAnimationIds: ['camera_button']),
              );
            },
          ),
        ),
        VisibilityAnimation(
          animationId: 'map_button',
          child: QuickActionCard(
            icon: Icons.map_rounded,
            title: 'Mapa',
            onTap: () {
              context.read<NavigationBloc>().add(const NavigateToPage(Routes.map));
            },
          ),
        ),
        VisibilityAnimation(
          animationId: 'light_button',
          child: QuickActionCard(
            icon: Icons.lightbulb_rounded,
            title: 'Luces',
            onTap: () {
              context.read<NavigationBloc>().add(const NavigateToPage(Routes.lights));
            },
          ),
        ),
        VisibilityAnimation(
          animationId: 'alarm_button',
          child: QuickActionCard(
            icon: Icons.shield_rounded,
            title: 'Alarma',
            onTap: () {
              context.read<NavigationBloc>().add(const NavigateToPage(Routes.alarm));
            },
          ),
        ),
      ],
    );
  }
}

class QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const QuickActionCard({super.key, required this.icon, required this.title, required this.onTap});

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isCamera = widget.title == 'Cámara';

    final cardContent = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF1E1E1E).withValues(alpha: 0.1), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: const Color(0xFF1E1E1E), size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Solo envolvemos con Hero si es la cámara
    if (isCamera) {
      return Hero(
        tag: 'camera-hero',
        child: Material(color: Colors.transparent, child: cardContent),
      );
    }

    return cardContent;
  }
}
