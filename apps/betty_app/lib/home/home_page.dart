import 'package:flutter/material.dart';
import '../shared/navigation/animations/visibility_animation.dart';
import 'widgets/app_bar/home_app_bar.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/battery_status_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: VisibilityAnimation(animationId: 'home_app_bar', child: HomeAppBar()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120),

                // Estado de batería destacado
                const VisibilityAnimation(animationId: 'battery_status_card', child: BatteryStatusCard()),

                const SizedBox(height: 80),

                // Grid de acciones rápidas
                const VisibilityAnimation(animationId: 'quick_actions_grid', child: QuickActionsGrid()),

                const SizedBox(height: 100),
                Center(
                  child: VisibilityAnimation(
                    animationId: 'footer_text',
                    child: Text(
                      'Disfruta de la Betty App',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF1E1E1E).withValues(alpha: 0.4),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
