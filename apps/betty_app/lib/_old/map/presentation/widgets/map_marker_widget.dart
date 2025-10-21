import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/map_location.dart';

class MapMarkerWidget extends StatelessWidget {
  final MapLocation location;

  const MapMarkerWidget({super.key, required this.location});

  static Marker createMarker(MapLocation location) {
    return Marker(
      point: LatLng(location.latitude, location.longitude),
      width: 40,
      height: 40,
      child: MapMarkerWidget(location: location),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.my_location,
      color: Colors.blue,
      size: 40,
      shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
    );
  }
}
