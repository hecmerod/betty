class GpsLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  const GpsLocation({required this.latitude, required this.longitude, required this.accuracy, required this.timestamp});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GpsLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          accuracy == other.accuracy &&
          timestamp == other.timestamp;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ accuracy.hashCode ^ timestamp.hashCode;

  @override
  String toString() {
    return 'GpsLocation(lat: ${latitude.toStringAsFixed(6)}, lng: ${longitude.toStringAsFixed(6)}, accuracy: ${accuracy.toStringAsFixed(1)}m)';
  }
}
