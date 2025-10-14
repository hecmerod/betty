import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/map_location.dart';
import '../../map_module.dart';
import '../providers/map_provider.dart';
import '../widgets/widgets.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: MapModule.providers, child: const _MapPageContent());
  }
}

class _MapPageContent extends StatefulWidget {
  const _MapPageContent();

  @override
  State<_MapPageContent> createState() => _MapPageContentState();
}

class _MapPageContentState extends State<_MapPageContent> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  bool _isFirstLocation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  Future<void> _initializeLocation() async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    await mapProvider.getCurrentLocation();

    mapProvider.startLocationStream();
  }

  void _updateMarker(MapLocation location) {
    final marker = MapMarkerWidget.createMarker(location);

    setState(() {
      _markers = [marker];

      if (_isFirstLocation) {
        _isFirstLocation = false;

        Future.delayed(const Duration(milliseconds: 100), () {
          _mapController.move(LatLng(location.latitude, location.longitude), 15.0);
        });
      }
    });
  }

  void _toggleMapType() {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    mapProvider.toggleMapView();
  }

  void _centerOnCurrentLocation() {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final location = mapProvider.currentLocation;

    if (location != null) {
      _mapController.move(LatLng(location.latitude, location.longitude), 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Consumer<MapProvider>(
        builder: (context, mapProvider, child) {
          if (mapProvider.currentLocation != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateMarker(mapProvider.currentLocation!);
            });
          }

          if (mapProvider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(mapProvider.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            });
          }

          return Stack(
            children: [
              MapViewWidget(
                mapController: _mapController,
                currentLocation: mapProvider.currentLocation,
                mapType: mapProvider.mapType,
                markers: _markers,
              ),

              if (mapProvider.isLoading) const MapLoadingWidget(),

              MapControlsWidget(
                currentMapType: mapProvider.mapType,
                onToggleMapType: _toggleMapType,
                onCenterLocation: _centerOnCurrentLocation,
              ),
            ],
          );
        },
      ),
    );
  }
}
