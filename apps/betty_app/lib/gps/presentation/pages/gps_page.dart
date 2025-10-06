import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/gps_location.dart';
import '../../gps_module.dart';
import '../providers/gps_provider.dart';
import '../widgets/widgets.dart';

class GpsPage extends StatelessWidget {
  const GpsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: GpsModule.providers, child: const _GpsPageContent());
  }
}

class _GpsPageContent extends StatefulWidget {
  const _GpsPageContent();

  @override
  State<_GpsPageContent> createState() => _GpsPageContentState();
}

class _GpsPageContentState extends State<_GpsPageContent> {
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
    final gpsProvider = Provider.of<GpsProvider>(context, listen: false);

    await gpsProvider.getCurrentLocation();

    gpsProvider.startLocationStream();
  }

  void _updateMarker(GpsLocation location) {
    final marker = GpsMarkerWidget.createMarker(location);

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
    final gpsProvider = Provider.of<GpsProvider>(context, listen: false);
    gpsProvider.toggleMapView();
  }

  void _centerOnCurrentLocation() {
    final gpsProvider = Provider.of<GpsProvider>(context, listen: false);
    final location = gpsProvider.currentLocation;

    if (location != null) {
      _mapController.move(LatLng(location.latitude, location.longitude), 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Consumer<GpsProvider>(
        builder: (context, gpsProvider, child) {
          if (gpsProvider.currentLocation != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateMarker(gpsProvider.currentLocation!);
            });
          }

          if (gpsProvider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(gpsProvider.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            });
          }

          return Stack(
            children: [
              GpsMapWidget(
                mapController: _mapController,
                currentLocation: gpsProvider.currentLocation,
                mapType: gpsProvider.mapType,
                markers: _markers,
              ),

              if (gpsProvider.isLoading) const GpsLoadingWidget(),

              GpsMapControlsWidget(
                currentMapType: gpsProvider.mapType,
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
