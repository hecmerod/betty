import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/trip_provider.dart';
import '../shared_widgets/info_card.dart';
import '../shared_widgets/trip_map_widget.dart';

class CurrentTripPage extends StatefulWidget {
  const CurrentTripPage({super.key});

  @override
  State<CurrentTripPage> createState() => _CurrentTripPageState();
}

class _CurrentTripPageState extends State<CurrentTripPage> {
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Future<void> _endTrip() async {
    final tripProvider = context.read<TripProvider>();
    final currentTrip = tripProvider.currentTrip;

    if (currentTrip == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Viaje'),
        content: Text('¿Estás seguro de que deseas finalizar el viaje "${currentTrip.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Finalizar')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await tripProvider.endTrip(currentTrip.id);

      if (result != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Viaje finalizado correctamente'), backgroundColor: Colors.green));
      } else if (mounted && tripProvider.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tripProvider.error!), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viaje en Progreso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TripProvider>().loadCurrentTrip();
            },
          ),
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          final currentTrip = tripProvider.currentTrip;

          if (currentTrip == null) {
            return const Center(child: Text('No hay viaje en progreso'));
          }

          final currentDuration = currentTrip.currentDuration;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tarjeta principal con información del viaje
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.directions_car, size: 64, color: Colors.blue),
                        const SizedBox(height: 16),
                        Text(
                          currentTrip.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer, size: 32, color: Colors.blue),
                              const SizedBox(width: 12),
                              Text(
                                _formatDuration(currentDuration),
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Mapa con las ubicaciones del viaje
                if (currentTrip.locations != null && currentTrip.locations!.isNotEmpty) ...[
                  Text(
                    'Ruta del Viaje',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TripMapWidget(locations: currentTrip.locations!, tripName: currentTrip.name),
                  const SizedBox(height: 24),
                ],

                // Información adicional
                InfoCard(
                  icon: Icons.play_circle_outline,
                  title: 'Inicio del Viaje',
                  value: _formatDate(currentTrip.startedAt),
                ),
                const SizedBox(height: 12),

                InfoCard(
                  icon: Icons.calendar_today,
                  title: 'Fecha de Creación',
                  value: _formatDate(currentTrip.createdAt),
                ),
                const SizedBox(height: 24),

                // Botón para finalizar viaje
                ElevatedButton.icon(
                  onPressed: tripProvider.isLoading ? null : _endTrip,
                  icon: const Icon(Icons.stop_circle),
                  label: const Text('Finalizar Viaje'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
