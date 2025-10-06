import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../domain/entities/map_type.dart';
import '../../domain/entities/gps_location.dart';
import '../../infrastructure/ioc/gps_module.dart';
import '../providers/gps_provider.dart';

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

    // Obtener la ubicación inicial
    await gpsProvider.getCurrentLocation();

    // Iniciar el stream de ubicaciones
    gpsProvider.startLocationStream();
  }

  void _updateMarker(GpsLocation location) {
    final marker = Marker(
      point: LatLng(location.latitude, location.longitude),
      width: 80,
      height: 80,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
      ),
    );

    setState(() {
      _markers = [marker];
      
      // Solo centrar el mapa la primera vez que se obtiene la ubicación
      if (_isFirstLocation) {
        _isFirstLocation = false;
        // Usar un pequeño delay para asegurar que el mapa esté listo
        Future.delayed(const Duration(milliseconds: 100), () {
          _mapController.move(
            LatLng(location.latitude, location.longitude),
            15.0,
          );
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
          // Actualizar marcador cuando cambie la ubicación
          if (gpsProvider.currentLocation != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateMarker(gpsProvider.currentLocation!);
            });
          }

          // Mostrar error si existe
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
              // Mapa
              if (gpsProvider.currentLocation != null)
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      gpsProvider.currentLocation!.latitude,
                      gpsProvider.currentLocation!.longitude,
                    ),
                    initialZoom: 15.0,
                    minZoom: 3.0,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: gpsProvider.mapType.tileUrl,
                      userAgentPackageName: 'com.example.betty_app',
                      maxZoom: 18,
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),

              // Indicador de carga
              if (gpsProvider.isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.blue),
                        SizedBox(height: 16),
                        Text('Obteniendo ubicación...', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                ),

              // Controles del mapa
              Positioned(
                top: 50,
                right: 16,
                child: Column(
                  children: [
                    // Botón cambiar tipo de mapa
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _toggleMapType,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Icon(
                                  gpsProvider.mapType == MapType.satellite ? Icons.map : Icons.satellite,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  gpsProvider.mapType == MapType.satellite ? 'Estándar' : 'Satélite',
                                  style: TextStyle(color: Colors.grey[700], fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Botón centrar ubicación
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _centerOnCurrentLocation,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(Icons.my_location, color: Colors.grey[700]),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Panel de información
              if (gpsProvider.currentLocation != null)
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.blue[600], size: 20),
                            const SizedBox(width: 8),
                            const Text('Ubicación Actual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildLocationInfo('Latitud', gpsProvider.currentLocation!.latitude.toStringAsFixed(6)),
                        const SizedBox(height: 4),
                        _buildLocationInfo('Longitud', gpsProvider.currentLocation!.longitude.toStringAsFixed(6)),
                        const SizedBox(height: 4),
                        _buildLocationInfo('Precisión', '${gpsProvider.currentLocation!.accuracy.toStringAsFixed(1)}m'),
                        const SizedBox(height: 4),
                        _buildLocationInfo(
                          'Última actualización',
                          _formatTimestamp(gpsProvider.currentLocation!.timestamp),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label:', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp).inSeconds;

    if (difference < 60) {
      return 'Hace $difference segundos';
    } else if (difference < 3600) {
      final minutes = difference ~/ 60;
      return 'Hace $minutes minutos';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
