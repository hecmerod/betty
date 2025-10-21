class Location {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? altitude;

  const Location({required this.latitude, required this.longitude, required this.timestamp, this.altitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      altitude: json['altitude'] != null ? (json['altitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      if (altitude != null) 'altitude': altitude,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timestamp == timestamp &&
        other.altitude == altitude;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^ longitude.hashCode ^ timestamp.hashCode ^ altitude.hashCode;
  }

  @override
  String toString() {
    return 'Location(lat: $latitude, lng: $longitude, time: $timestamp${altitude != null ? ', alt: $altitude' : ''})';
  }
}
