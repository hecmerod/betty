import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import 'current_trip/current_trip_page.dart';
import 'trips_list/trips_list_page.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  @override
  void initState() {
    super.initState();
    // Inicializar DESPUÉS de que el widget tree esté completo
    Future.delayed(Duration.zero, () {
      if (mounted) {
        final tripProvider = context.read<TripProvider>();
        if (!tripProvider.isInitialized) {
          tripProvider.initializeTripsState();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<TripProvider, _TripsState>(
      selector: (context, provider) => _TripsState(
        isInitialized: provider.isInitialized,
        isLoading: provider.isLoading,
        error: provider.error,
        hasTripInProgress: provider.hasTripInProgress,
        hasCurrentTrip: provider.currentTrip != null,
      ),
      builder: (context, state, child) {
        // Mostrar loading si no está inicializado
        if (!state.isInitialized) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error al cargar los viajes', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      final tripProvider = context.read<TripProvider>();
                      tripProvider.initializeTripsState();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        // Si hay un trip en progreso, mostrar CurrentTripPage
        if (state.hasTripInProgress && state.hasCurrentTrip) {
          return const CurrentTripPage();
        }

        // Si no hay trip en progreso, mostrar lista de trips
        return const TripsListPage();
      },
    );
  }
}

// Clase para selector
class _TripsState {
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final bool hasTripInProgress;
  final bool hasCurrentTrip;

  _TripsState({
    required this.isInitialized,
    required this.isLoading,
    required this.error,
    required this.hasTripInProgress,
    required this.hasCurrentTrip,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TripsState &&
          runtimeType == other.runtimeType &&
          isInitialized == other.isInitialized &&
          isLoading == other.isLoading &&
          error == other.error &&
          hasTripInProgress == other.hasTripInProgress &&
          hasCurrentTrip == other.hasCurrentTrip;

  @override
  int get hashCode =>
      isInitialized.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      hasTripInProgress.hashCode ^
      hasCurrentTrip.hashCode;
}
