import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/trip_provider.dart';
import '../../domain/entities/trip.dart';

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
                    _InfoCard(
                      icon: Icons.timer,
                      title: 'Duración Total',
                      value: _formatDuration(_trip!.duration!),
                      color: Colors.blue,
                    ),
                  if (_trip!.duration != null) const SizedBox(height: 12),

                  // Fecha de inicio
                  _InfoCard(
                    icon: Icons.play_circle_outline,
                    title: 'Inicio del Viaje',
                    value: _formatDate(_trip!.startedAt),
                    subtitle: _formatDateLong(_trip!.startedAt),
                  ),
                  const SizedBox(height: 12),

                  // Fecha de finalización
                  if (_trip!.endedAt != null) ...[
                    _InfoCard(
                      icon: Icons.stop_circle_outlined,
                      title: 'Fin del Viaje',
                      value: _formatDate(_trip!.endedAt!),
                      subtitle: _formatDateLong(_trip!.endedAt!),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Fecha de creación
                  _InfoCard(
                    icon: Icons.calendar_today,
                    title: 'Fecha de Creación',
                    value: _formatDate(_trip!.createdAt),
                  ),
                  const SizedBox(height: 12),

                  // Última actualización
                  _InfoCard(icon: Icons.update, title: 'Última Actualización', value: _formatDate(_trip!.updatedAt)),
                ],
              ),
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color? color;

  const _InfoCard({required this.icon, required this.title, required this.value, this.subtitle, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.grey, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: color),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
