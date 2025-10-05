class MemoryInfo {
  final int used;
  final int total;
  final int rss;

  const MemoryInfo({
    required this.used,
    required this.total,
    required this.rss,
  });

  double get usagePercentage => total > 0 ? (used / total) * 100 : 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoryInfo &&
        other.used == used &&
        other.total == total &&
        other.rss == rss;
  }

  @override
  int get hashCode => used.hashCode ^ total.hashCode ^ rss.hashCode;

  @override
  String toString() => 'MemoryInfo(used: $used, total: $total, rss: $rss)';
}
