import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entities/location.dart' as trip_location;

class TripMapWidget extends StatelessWidget {
  final List<trip_location.Location> locations;
  final String tripName;

  const TripMapWidget({super.key, required this.locations, required this.tripName});

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return Card(
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No hay ubicaciones registradas',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Convertir locations a LatLng
    final points = locations.map((loc) => LatLng(loc.latitude, loc.longitude)).toList();

    // Calcular el centro del mapa
    final center = _calculateCenter(points);

    // Calcular el zoom apropiado
    final bounds = LatLngBounds.fromPoints(points);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: _calculateZoom(bounds), minZoom: 5, maxZoom: 18),
              children: [
                // Capa del mapa
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.betty.app',
                ),
                // Polilínea conectando las ubicaciones
                PolylineLayer(
                  polylines: [Polyline(points: points, color: Colors.blue, strokeWidth: 4.0)],
                ),
                // Marcadores
                MarkerLayer(
                  markers: [
                    // Marcador de inicio (verde)
                    if (points.isNotEmpty)
                      Marker(
                        point: points.first,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.flag, color: Colors.green, size: 40),
                      ),
                    // Marcador de fin (rojo) - solo si hay más de un punto
                    if (points.length > 1)
                      Marker(
                        point: points.last,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.flag, color: Colors.red, size: 40),
                      ),
                  ],
                ),
              ],
            ),
            // Badge con información
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${locations.length} puntos',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LatLng _calculateCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);

    double sumLat = 0;
    double sumLng = 0;

    for (final point in points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }

    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  double _calculateZoom(LatLngBounds bounds) {
    final latDiff = bounds.north - bounds.south;
    final lngDiff = bounds.east - bounds.west;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    if (maxDiff > 10) return 5;
    if (maxDiff > 5) return 6;
    if (maxDiff > 2) return 8;
    if (maxDiff > 1) return 10;
    if (maxDiff > 0.5) return 11;
    if (maxDiff > 0.1) return 13;
    if (maxDiff > 0.05) return 14;
    return 15;
  }
}
