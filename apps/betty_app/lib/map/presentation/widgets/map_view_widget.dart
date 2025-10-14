import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/map_location.dart';
import '../../domain/entities/map_type.dart';

class MapViewWidget extends StatelessWidget {
  final MapController mapController;
  final MapLocation? currentLocation;
  final MapType mapType;
  final List<Marker> markers;

  const MapViewWidget({
    super.key,
    required this.mapController,
    required this.currentLocation,
    required this.mapType,
    required this.markers,
  });

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const SizedBox.shrink();
    }

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(currentLocation!.latitude, currentLocation!.longitude),
        initialZoom: 15.0,
        minZoom: 3.0,
        maxZoom: 18.0,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        TileLayer(
          urlTemplate: mapType.tileUrl,
          userAgentPackageName: 'com.example.betty_app',
          maxZoom: 18,
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
