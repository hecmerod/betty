import 'package:betty_app/home/presentation/widgets/dashboard/device_toggles.dart';
import 'package:flutter/material.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    final double inset = height / 40;
    final double navClearance = inset * 2 + height / 12;

    return Padding(padding: EdgeInsets.fromLTRB(inset, inset, inset, navClearance), child: const DeviceToggles());
  }
}
