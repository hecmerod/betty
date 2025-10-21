import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui';
import '../shared/services/gps_service.dart';
import 'widgets/location_button.dart';
import 'widgets/vehicle_location_button.dart';
import 'services/map_api_service.dart';
import '../shared/theme/app_theme.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final _gpsService = GpsService.instance;
  final _mapApiService = MapApiService.instance;
  LatLng _currentLocation = const LatLng(39.4699, -0.3763);
  LatLng? _vehicleLocation;
  bool _isLoading = false;
  bool _isLoadingVehicle = false;
  bool _locationObtained = false;
  bool _vehicleLocationObtained = false;

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

  Future<void> _getVehicleLocation() async {
    if (_isLoadingVehicle) return;

    setState(() => _isLoadingVehicle = true);

    try {
      final vehicleData = await _mapApiService.getVehicleLocation();

      if (mounted) {
        setState(() {
          _vehicleLocation = vehicleData.position;
          _vehicleLocationObtained = true;
        });

        await Future.delayed(const Duration(milliseconds: 100));
        _mapController.move(_vehicleLocation!, 15.0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación de la furgoneta: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingVehicle = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: AppTheme.primaryGradientMiddle),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Text(
                'Mapa',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGradientMiddle),
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
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
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.cameraGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4facfe).withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_pin_rounded, color: Colors.white, size: 30),
                      ),
                    ),
                    if (_vehicleLocationObtained && _vehicleLocation != null)
                      Marker(
                        point: _vehicleLocation!,
                        width: 60,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.mapGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF43e97b).withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 35),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                VehicleLocationButton(isLoading: _isLoadingVehicle, onPressed: _getVehicleLocation),
                const SizedBox(height: 12),
                LocationButton(isLoading: _isLoading, onPressed: _getCurrentLocation),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
