import '../../domain/entities/health_data.dart';
import 'memory_info_model.dart';

class HealthDataModel extends HealthData {
  const HealthDataModel({
    required super.status,
    required super.timestamp,
    required super.uptime,
    required super.memory,
  });

  factory HealthDataModel.fromJson(Map<String, dynamic> json) {
    return HealthDataModel(
      status: json['status'] ?? 'unknown',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      uptime: (json['uptime'] ?? 0).toDouble(),
      memory: MemoryInfoModel.fromJson(json['memory'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'uptime': uptime,
      'memory': (memory as MemoryInfoModel).toJson(),
    };
  }

  HealthData toEntity() {
    return HealthData(
      status: status,
      timestamp: timestamp,
      uptime: uptime,
      memory: memory,
    );
  }
}
