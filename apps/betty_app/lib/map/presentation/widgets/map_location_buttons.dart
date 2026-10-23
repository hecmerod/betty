import 'package:betty_app/map/application/map_bloc/map_bloc.dart';
import 'package:betty_app/map/application/map_bloc/map_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _deviceColor = Color(0xFF2563EB);
const _serverColor = Color(0xFF43e97b);
const _ink = Color(0xFF1E1E1E);

class MapLocationButtons extends StatelessWidget {
  const MapLocationButtons({
    super.key,
    required this.onGoToDevice,
    required this.onGoToServer,
  });

  final VoidCallback onGoToDevice;
  final VoidCallback onGoToServer;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoundMapButton(
              key: const ValueKey('map-server-location-button'),
              icon: Icons.directions_car_rounded,
              color: _serverColor,
              tooltip: 'Ir a Betty',
              enabled: state.serverLocation != null,
              loading: state.isLoadingServer,
              onPressed: onGoToServer,
            ),
            const SizedBox(height: 12),
            _RoundMapButton(
              key: const ValueKey('map-device-location-button'),
              icon: Icons.my_location_rounded,
              color: _deviceColor,
              tooltip: 'Ir a tu ubicación',
              enabled: state.deviceLocation != null,
              loading: state.isLoadingDevice,
              onPressed: onGoToDevice,
            ),
          ],
        );
      },
    );
  }
}

class _RoundMapButton extends StatelessWidget {
  const _RoundMapButton({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isActive = enabled || loading;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Center(
                child: loading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: color,
                        ),
                      )
                    : Icon(
                        icon,
                        color: isActive ? color : _ink.withValues(alpha: 0.35),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
