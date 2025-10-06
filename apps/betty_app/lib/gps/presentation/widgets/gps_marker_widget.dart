import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/gps_location.dart';

class GpsMarkerWidget extends StatelessWidget {
  final GpsLocation location;

  const GpsMarkerWidget({super.key, required this.location});

  static Marker createMarker(GpsLocation location) {
    return Marker(
      point: LatLng(location.latitude, location.longitude),
      width: 80,
      height: 80,
      child: GpsMarkerWidget(location: location),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
    );
  }
}
