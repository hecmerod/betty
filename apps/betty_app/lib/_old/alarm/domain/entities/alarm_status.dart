class AlarmStatus {
  final bool isActive;
  final String status;
  final DateTime timestamp;

  const AlarmStatus({required this.isActive, required this.status, required this.timestamp});

  factory AlarmStatus.fromJson(Map<String, dynamic> json) {
    return AlarmStatus(
      isActive: json['active'] ?? false,
      status: json['status'] ?? 'inactive',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'active': isActive, 'status': status, 'timestamp': timestamp.toIso8601String()};
  }

  AlarmStatus copyWith({bool? isActive, String? status, DateTime? timestamp}) {
    return AlarmStatus(
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'AlarmStatus(isActive: $isActive, status: $status, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlarmStatus && other.isActive == isActive && other.status == status && other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return isActive.hashCode ^ status.hashCode ^ timestamp.hashCode;
  }
}
