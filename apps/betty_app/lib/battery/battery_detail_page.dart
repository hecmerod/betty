import 'package:flutter/material.dart';
import 'dart:ui';
import '../shared/theme/app_theme.dart';
import 'widgets/vertical_battery_card.dart';
import 'widgets/battery_info_section.dart';

class BatteryDetailPage extends StatefulWidget {
  const BatteryDetailPage({super.key});

  @override
  State<BatteryDetailPage> createState() => _BatteryDetailPageState();
}

class _BatteryDetailPageState extends State<BatteryDetailPage> with TickerProviderStateMixin {
  late AnimationController _waveController1;
  late AnimationController _waveController2;

  @override
  void initState() {
    super.initState();
    _waveController1 = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

    _waveController2 = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _waveController1.dispose();
    _waveController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double battery1Percentage = 62;
    const double battery1PowerWatts = 0.0;
    const double battery2Percentage = 78;
    const double battery2PowerWatts = -150.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        title: const Text(
          'Estado de Baterías',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryGradientStart, AppTheme.primaryGradientMiddle, AppTheme.primaryGradientEnd],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 160),

              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: VerticalBatteryCard(
                        percentage: battery1Percentage,
                        powerWatts: battery1PowerWatts,
                        waveController: _waveController1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: VerticalBatteryCard(
                      percentage: battery2Percentage,
                      powerWatts: battery2PowerWatts,
                      waveController: _waveController2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              BatteryInfoSection(
                battery1Percentage: battery1Percentage,
                battery1PowerWatts: battery1PowerWatts,
                battery2Percentage: battery2Percentage,
                battery2PowerWatts: battery2PowerWatts,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
