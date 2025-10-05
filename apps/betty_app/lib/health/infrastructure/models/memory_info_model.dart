import '../../domain/entities/memory_info.dart';

class MemoryInfoModel extends MemoryInfo {
  const MemoryInfoModel({
    required super.used,
    required super.total,
    required super.rss,
  });

  factory MemoryInfoModel.fromJson(Map<String, dynamic> json) {
    return MemoryInfoModel(
      used: json['used'] ?? 0,
      total: json['total'] ?? 0,
      rss: json['rss'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'used': used, 'total': total, 'rss': rss};
  }

  MemoryInfo toEntity() {
    return MemoryInfo(used: used, total: total, rss: rss);
  }
}
