import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class GpsPage extends StatefulWidget {
  const GpsPage({super.key});

  @override
  State<GpsPage> createState() => _GpsPageState();
}

class _GpsPageState extends State<GpsPage> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  late StreamSubscription<Position> _positionStream;
  List<Marker> _markers = [];
  bool _isSatelliteView = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      // Verificar permisos de localización
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Permisos de localización denegados';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Permisos de localización permanentemente denegados';
          _isLoading = false;
        });
        return;
      }

      // Verificar si el servicio de localización está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Servicio de localización deshabilitado';
          _isLoading = false;
        });
        return;
      }

      // Obtener posición actual
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
        _updateMarker(position);
      });

      // Mover el mapa a la posición actual después de que se renderice
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
      });

      // Configurar stream para actualizaciones en tiempo real
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10, // Actualizar cada 10 metros
            ),
          ).listen((Position position) {
            setState(() {
              _currentPosition = position;
              _updateMarker(position);
            });

            // Mover el mapa a la nueva posición de forma segura
            if (_mapController.camera.zoom > 0) {
              _mapController.move(LatLng(position.latitude, position.longitude), _mapController.camera.zoom);
            }
          });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener localización: $e';
        _isLoading = false;
      });
    }
  }

  void _updateMarker(Position position) {
    _markers = [
      Marker(
        point: LatLng(position.latitude, position.longitude),
        child: const Icon(Icons.location_on, color: Colors.green, size: 40),
      ),
    ];
  }

  void _centerOnLocation() {
    if (_currentPosition != null && _mapController.camera.zoom > 0) {
      _mapController.move(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 15.0);
    }
  }

  void _toggleMapType() {
    setState(() {
      _isSatelliteView = !_isSatelliteView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ Betty GPS'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isSatelliteView ? Icons.map : Icons.satellite_alt),
            onPressed: _toggleMapType,
            tooltip: _isSatelliteView ? 'Vista Estándar' : 'Vista Satélite',
          ),
          if (_currentPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _centerOnLocation,
              tooltip: 'Centrar en mi ubicación',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Obteniendo localización GPS...')],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _initializeLocation();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : const LatLng(40.4168, -3.7038), // Madrid por defecto
                    initialZoom: 15.0,
                    minZoom: 3.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _isSatelliteView
                          ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.betty_app',
                      maxNativeZoom: 19,
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
                if (_currentPosition != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.green),
                              SizedBox(width: 4),
                              Text('Localización Actual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Precisión: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _isSatelliteView ? Icons.satellite_alt : Icons.map,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isSatelliteView ? 'Vista Satélite' : 'Vista Estándar',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
