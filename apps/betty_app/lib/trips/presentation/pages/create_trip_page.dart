import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    final tripProvider = context.read<TripProvider>();
    final trip = await tripProvider.createTrip(_nameController.text.trim());

    if (mounted) {
      setState(() {
        _isCreating = false;
      });

      if (trip != null) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Viaje creado correctamente'), backgroundColor: Colors.green));
        // Volver a la pantalla anterior
        Navigator.pop(context);
      } else if (tripProvider.error != null) {
        // Mostrar error
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tripProvider.error!), backgroundColor: Colors.red));
        tripProvider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Viaje')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono
              const Icon(Icons.add_road, size: 80, color: Colors.blue),
              const SizedBox(height: 24),

              // Título
              Text(
                'Crear Nuevo Viaje',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Introduce un nombre para tu viaje',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Campo de nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Viaje',
                  hintText: 'Ej: Viaje a Madrid',
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor introduce un nombre';
                  }
                  if (value.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
                enabled: !_isCreating,
              ),
              const SizedBox(height: 24),

              // Información adicional
              Card(
                color: Colors.blue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'El viaje comenzará inmediatamente',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Solo puedes tener un viaje en progreso a la vez. Finaliza el viaje actual antes de crear uno nuevo.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botón crear
              ElevatedButton.icon(
                onPressed: _isCreating ? null : _createTrip,
                icon: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.add_circle),
                label: Text(_isCreating ? 'Creando...' : 'Crear Viaje'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Botón cancelar
              OutlinedButton(
                onPressed: _isCreating ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
