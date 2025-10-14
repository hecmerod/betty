import 'package:flutter/material.dart';
import '../../domain/entities/map_type.dart';

class MapControlsWidget extends StatelessWidget {
  final MapType currentMapType;
  final VoidCallback onToggleMapType;
  final VoidCallback onCenterLocation;
  final VoidCallback onCenterVehicle;

  const MapControlsWidget({
    super.key,
    required this.currentMapType,
    required this.onToggleMapType,
    required this.onCenterLocation,
    required this.onCenterVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 16,
      child: Column(
        children: [
          _MapControlButton(
            onTap: onToggleMapType,
            icon: currentMapType == MapType.satellite ? Icons.map : Icons.satellite,
            label: currentMapType == MapType.satellite ? 'Estándar' : 'Satélite',
          ),
          const SizedBox(height: 12),
          _MapControlButton(onTap: onCenterLocation, icon: Icons.my_location, label: 'Mi posición'),
          const SizedBox(height: 12),
          _MapControlButton(onTap: onCenterVehicle, icon: Icons.local_shipping, label: 'Vehículo'),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String? label;

  const _MapControlButton({required this.onTap, required this.icon, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: label != null
                ? Column(
                    children: [
                      Icon(icon, color: Colors.grey[700]),
                      const SizedBox(height: 4),
                      Text(label!, style: TextStyle(color: Colors.grey[700], fontSize: 10)),
                    ],
                  )
                : Icon(icon, color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}
