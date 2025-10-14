import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/trip_provider.dart';
import '../../../domain/entities/trip.dart';
import '../shared_widgets/info_card.dart';

class TripDetailPage extends StatefulWidget {
  final String tripId;

  const TripDetailPage({super.key, required this.tripId});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  Trip? _trip;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    setState(() {
      _isLoading = true;
    });

    final tripProvider = context.read<TripProvider>();
    final trip = await tripProvider.getTripById(widget.tripId);

    setState(() {
      _trip = trip;
      _isLoading = false;
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatDateLong(DateTime date) {
    // Formato largo sin locale específico para evitar error de inicialización
    return DateFormat('dd/MM/yyyy - HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Viaje'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTrip)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trip == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Viaje no encontrado', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta principal
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            _trip!.isCompleted ? Icons.check_circle : Icons.play_circle,
                            size: 64,
                            color: _trip!.isCompleted ? Colors.green : Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _trip!.name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (_trip!.isCompleted ? Colors.green : Colors.blue).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _trip!.isCompleted ? 'Completado' : 'En Progreso',
                              style: TextStyle(
                                color: _trip!.isCompleted ? Colors.green : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Duración
                  if (_trip!.duration != null)
                    InfoCard(
                      icon: Icons.timer,
                      title: 'Duración Total',
                      value: _formatDuration(_trip!.duration!),
                      color: Colors.blue,
                    ),
                  if (_trip!.duration != null) const SizedBox(height: 12),

                  // Fecha de inicio
                  InfoCard(
                    icon: Icons.play_circle_outline,
                    title: 'Inicio del Viaje',
                    value: _formatDate(_trip!.startedAt),
                    subtitle: _formatDateLong(_trip!.startedAt),
                  ),
                  const SizedBox(height: 12),

                  // Fecha de finalización
                  if (_trip!.endedAt != null) ...[
                    InfoCard(
                      icon: Icons.stop_circle_outlined,
                      title: 'Fin del Viaje',
                      value: _formatDate(_trip!.endedAt!),
                      subtitle: _formatDateLong(_trip!.endedAt!),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Fecha de creación
                  InfoCard(
                    icon: Icons.calendar_today,
                    title: 'Fecha de Creación',
                    value: _formatDate(_trip!.createdAt),
                  ),
                  const SizedBox(height: 12),

                  // Última actualización
                  InfoCard(icon: Icons.update, title: 'Última Actualización', value: _formatDate(_trip!.updatedAt)),
                ],
              ),
            ),
    );
  }
}
