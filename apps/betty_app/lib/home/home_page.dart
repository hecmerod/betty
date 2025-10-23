import 'package:flutter/material.dart';
import '../shared/navigation/animations/hide_widget_animation.dart';
import 'widgets/app_bar/home_app_bar.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/battery_status_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: VisibilityAnimation(animationId: 'home_app_bar', child: HomeAppBar()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            const VisibilityAnimation(animationId: 'battery_status_card', child: BatteryStatusCard()),

            const Spacer(),
            const Spacer(),

            const VisibilityAnimation(
              animationId: 'quick_actions_grid',
              child: Padding(padding: EdgeInsets.symmetric(horizontal: 24.0), child: QuickActionsGrid()),
            ),

            const SizedBox(height: 24),

            const Spacer(),

            VisibilityAnimation(
              animationId: 'quick_actions_grid',
              child: Text(
                'Disfruta de la betty app',
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
