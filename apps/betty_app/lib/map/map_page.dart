import 'package:betty_app/shared/widgets/secondary_page_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final _gpsService = GpsService.instance;
  final _mapApiService = MapApiService.instance;
  LatLng _currentLocation = const LatLng(39.4699, -0.3763);
  LatLng? _vehicleLocation;
  bool _locationObtained = false;
  bool _vehicleLocationObtained = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLocations();
    });
  }

  Future<void> _loadLocations() async {
    // Cargar ambas ubicaciones al inicio
    await Future.wait([_fetchCurrentLocation(), _fetchVehicleLocation()]);
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final location = await _gpsService.getCurrentLocation();

      if (location != null && mounted) {
        setState(() {
          _currentLocation = location;
          _locationObtained = true;
        });

        // Animar a la ubicación del usuario al inicio
        await Future.delayed(const Duration(milliseconds: 100));
        _animateToLocation(_currentLocation, 15.0);
      }
    } catch (e) {
      debugPrint('Error al obtener ubicación del usuario: $e');
    }
  }

  Future<void> _fetchVehicleLocation() async {
    try {
      final vehicleData = await _mapApiService.getVehicleLocation();

      if (mounted) {
        setState(() {
          _vehicleLocation = vehicleData.position;
          _vehicleLocationObtained = true;
        });
      }
    } catch (e) {
      debugPrint('Error al obtener ubicación de la furgoneta: $e');
    }
  }

  void _animateToCurrentLocation() {
    if (_locationObtained) {
      _animateToLocation(_currentLocation, 15.0);
    }
  }

  void _animateToVehicleLocation() {
    if (_vehicleLocationObtained && _vehicleLocation != null) {
      _animateToLocation(_vehicleLocation!, 15.0);
    }
  }

  void _animateToLocation(LatLng destination, double zoom) {
    final camera = _mapController.camera;
    final latTween = Tween<double>(begin: camera.center.latitude, end: destination.latitude);
    final lngTween = Tween<double>(begin: camera.center.longitude, end: destination.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: zoom);

    final controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: SecondaryPageAppBar(title: 'Mapa', backgroundOpacity: 0.8),
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
                              color: const Color(0xFF4facfe).withValues(alpha: 0.5),
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
                                color: const Color(0xFF43e97b).withValues(alpha: 0.5),
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
                VehicleLocationButton(isLoading: false, onPressed: _animateToVehicleLocation),
                const SizedBox(height: 12),
                LocationButton(isLoading: false, onPressed: _animateToCurrentLocation),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
