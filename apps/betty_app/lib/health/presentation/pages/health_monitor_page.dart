import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_monitor_provider.dart';
import '../widgets/status_card.dart';
import '../widgets/uptime_card.dart';
import '../widgets/memory_card.dart';
import '../widgets/timestamp_card.dart';
import '../../../auth/presentation/widgets/protected_section.dart';
import '../widgets/error_card.dart';

class HealthMonitorPage extends StatefulWidget {
  const HealthMonitorPage({super.key});

  @override
  State<HealthMonitorPage> createState() => _HealthMonitorPageState();
}

class _HealthMonitorPageState extends State<HealthMonitorPage> {
  @override
  void initState() {
    super.initState();
    // Start auto-refresh when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthMonitorProvider>().startAutoRefresh();
    });
  }

  @override
  void dispose() {
    context.read<HealthMonitorProvider>().stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍓 Betty Health Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          Consumer<HealthMonitorProvider>(
            builder: (context, provider, _) {
              return IconButton(
                onPressed: provider.isHealthLoading
                    ? null
                    : provider.fetchHealthData,
                icon: provider.isHealthLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: Consumer<HealthMonitorProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: provider.fetchHealthData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StatusCard(healthData: provider.healthData),
                  const SizedBox(height: 16),
                  if (provider.healthData != null) ...[
                    UptimeCard(healthData: provider.healthData!),
                    const SizedBox(height: 16),
                    MemoryCard(healthData: provider.healthData!),
                    const SizedBox(height: 16),
                    TimestampCard(healthData: provider.healthData!),
                    const SizedBox(height: 16),
                    const ProtectedSection(),
                  ],
                  if (provider.healthError != null)
                    ErrorCard(error: provider.healthError!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
