import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../shared/services/gps_service.dart';
import 'widgets/location_button.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final _gpsService = GpsService.instance;
  LatLng _currentLocation = const LatLng(39.4699, -0.3763);
  bool _isLoading = false;
  bool _locationObtained = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final location = await _gpsService.getCurrentLocation();

      if (location == null) {
        setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        setState(() {
          _currentLocation = location;
          _locationObtained = true;
        });

        await Future.delayed(const Duration(milliseconds: 100));
        _mapController.move(_currentLocation, 15.0);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa'), backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.betty_app',
                maxZoom: 19,
                errorTileCallback: (tile, error, stackTrace) {},
              ),
              if (_locationObtained)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 40),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: 24,
            right: 16,
            child: LocationButton(isLoading: _isLoading, onPressed: _getCurrentLocation),
          ),
        ],
      ),
    );
  }
}
