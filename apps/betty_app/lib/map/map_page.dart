import 'package:betty_app/shared/widgets/secondary_page_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../shared/services/gps_service.dart';
import '../shared/theme/app_theme.dart';
import 'models/location_record.dart';
import 'services/map_api_service.dart';
import 'widgets/location_button.dart';
import 'widgets/locations_list.dart';
import 'widgets/vehicle_location_button.dart';

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
  List<LocationRecord> _trackedLocations = [];
  bool _locationsLoading = true;
  int? _selectedLocationIndex;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLocations();
    });
  }

  Future<void> _loadLocations() async {
    await Future.wait([_fetchCurrentLocation(), _fetchVehicleLocation(), _fetchTrackedLocations()]);
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final location = await _gpsService.getCurrentLocation();

      if (location != null && mounted) {
        setState(() {
          _currentLocation = location;
          _locationObtained = true;
        });

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

  Future<void> _fetchTrackedLocations() async {
    setState(() {
      _locationsLoading = true;
      _selectedLocationIndex = null;
    });

    try {
      final locations = await _mapApiService.getAllLocations(from: _from, to: _to);

      if (mounted) {
        setState(() {
          _trackedLocations = locations;
          _locationsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error al obtener el historial de ubicaciones: $e');
      if (mounted) {
        setState(() => _locationsLoading = false);
      }
    }
  }

  void _onFromSelected(DateTime date) {
    setState(() {
      _from = DateTime(date.year, date.month, date.day);
      if (_to != null && _from!.isAfter(_to!)) {
        _to = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
      }
    });
    _fetchTrackedLocations();
  }

  void _onToSelected(DateTime date) {
    setState(() {
      _to = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
      if (_from != null && _from!.isAfter(_to!)) {
        _from = DateTime(date.year, date.month, date.day);
      }
    });
    _fetchTrackedLocations();
  }

  void _onFilterCleared() {
    setState(() {
      _from = null;
      _to = null;
    });
    _fetchTrackedLocations();
  }

  void _animateToCurrentLocation() {
    if (_locationObtained) {
      setState(() => _selectedLocationIndex = null);
      _animateToLocation(_currentLocation, 15.0);
    }
  }

  void _animateToVehicleLocation() {
    if (_vehicleLocationObtained && _vehicleLocation != null) {
      setState(() => _selectedLocationIndex = null);
      _animateToLocation(_vehicleLocation!, 15.0);
    }
  }

  void _onTrackedLocationSelected(int index) {
    setState(() => _selectedLocationIndex = index);
    _animateToLocation(_trackedLocations[index].position, 16.0);
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
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    for (var i = 0; i < _trackedLocations.length; i++) {
      final isSelected = _selectedLocationIndex == i;
      markers.add(
        Marker(
          point: _trackedLocations[i].position,
          width: isSelected ? 28 : 18,
          height: isSelected ? 28 : 18,
          child: GestureDetector(
            onTap: () => _onTrackedLocationSelected(i),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF43e97b) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF43e97b), width: isSelected ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF43e97b).withValues(alpha: isSelected ? 0.5 : 0.3),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_locationObtained) {
      markers.add(
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
      );
    }

    if (_vehicleLocationObtained && _vehicleLocation != null) {
      markers.add(
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
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final pathPoints = _trackedLocations.reversed.map((location) => location.position).toList();

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
              if (pathPoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: pathPoints,
                      color: const Color(0xFF43e97b),
                      strokeWidth: 4,
                      borderColor: Colors.white,
                      borderStrokeWidth: 1,
                    ),
                  ],
                ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.32,
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
          DraggableScrollableSheet(
            initialChildSize: 0.34,
            minChildSize: 0.22,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return LocationsList(
                locations: _trackedLocations,
                isLoading: _locationsLoading,
                selectedIndex: _selectedLocationIndex,
                scrollController: scrollController,
                onLocationSelected: _onTrackedLocationSelected,
                from: _from,
                to: _to,
                onFromSelected: _onFromSelected,
                onToSelected: _onToSelected,
                onFilterCleared: _onFilterCleared,
              );
            },
          ),
        ],
      ),
    );
  }
}
