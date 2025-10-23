import 'package:flutter/material.dart';
import 'widgets/app_bar/home_app_bar.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/battery_status_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            const BatteryStatusCard(),

            const Spacer(),
            const Spacer(),

            const Padding(padding: EdgeInsets.symmetric(horizontal: 24.0), child: QuickActionsGrid()),

            const SizedBox(height: 24),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Text(
                'Disfruta de la betty app',
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
