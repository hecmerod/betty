import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/map_location.dart';

class VehicleMarkerWidget extends StatelessWidget {
  final MapLocation location;

  const VehicleMarkerWidget({super.key, required this.location});

  static Marker createMarker(MapLocation location) {
    return Marker(
      point: LatLng(location.latitude, location.longitude),
      width: 45,
      height: 45,
      child: VehicleMarkerWidget(location: location),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.local_shipping,
      color: Colors.green,
      size: 45,
      shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
    );
  }
}
