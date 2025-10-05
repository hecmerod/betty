import 'memory_info.dart';

class HealthData {
  final String status;
  final DateTime timestamp;
  final double uptime;
  final MemoryInfo memory;

  const HealthData({
    required this.status,
    required this.timestamp,
    required this.uptime,
    required this.memory,
  });

  String get formattedUptime {
    final hours = (uptime / 3600).floor();
    final minutes = ((uptime % 3600) / 60).floor();
    final seconds = (uptime % 60).floor();

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  bool get isHealthy => status.toLowerCase() == 'ok';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthData &&
        other.status == status &&
        other.timestamp == timestamp &&
        other.uptime == uptime &&
        other.memory == memory;
  }

  @override
  int get hashCode =>
      status.hashCode ^ timestamp.hashCode ^ uptime.hashCode ^ memory.hashCode;

  @override
  String toString() =>
      'HealthData(status: $status, timestamp: $timestamp, uptime: $uptime, memory: $memory)';
}
