import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/error_type.dart';
import '../../domain/models/error_severity.dart';

class ErrorDialog extends StatelessWidget {
  final AppError error;

  const ErrorDialog({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          _buildErrorIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error.message, style: Theme.of(context).textTheme.bodyMedium),
          if (error.technicalDetails != null) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Detalles técnicos'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.all(8),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              error.technicalDetails!,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _copyToClipboard(context),
                            icon: const Icon(Icons.copy, size: 16),
                            tooltip: 'Copiar detalles',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Error ID: ${error.id}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                      Text(
                        'Tiempo: ${_formatTimestamp(error.timestamp)}',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        if (error.severity == ErrorSeverity.critical)
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar App')),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
        if (_shouldShowRetryButton())
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleRetry();
            },
            child: const Text('Reintentar'),
          ),
      ],
    );
  }

  Widget _buildErrorIcon() {
    IconData iconData;
    Color color;

    switch (error.severity) {
      case ErrorSeverity.info:
        iconData = Icons.info_outline;
        color = Colors.blue;
        break;
      case ErrorSeverity.warning:
        iconData = Icons.warning_amber;
        color = Colors.orange;
        break;
      case ErrorSeverity.error:
        iconData = Icons.error_outline;
        color = Colors.red;
        break;
      case ErrorSeverity.critical:
        iconData = Icons.dangerous;
        color = Colors.red.shade800;
        break;
    }

    return Icon(iconData, color: color, size: 28);
  }

  bool _shouldShowRetryButton() {
    switch (error.type) {
      case ErrorType.network:
      case ErrorType.firebase:
        return true;
      case ErrorType.authentication:
      case ErrorType.validation:
      case ErrorType.permission:
      case ErrorType.storage:
      case ErrorType.unknown:
        return false;
    }
  }

  void _handleRetry() {
    switch (error.type) {
      case ErrorType.network:
        break;
      case ErrorType.firebase:
        break;
      default:
        break;
    }
  }

  void _copyToClipboard(BuildContext context) {
    final details =
        '''
Error ID: ${error.id}
Tipo: ${error.type.name}
Severidad: ${error.severity.name}
Título: ${error.title}
Mensaje: ${error.message}
Detalles técnicos: ${error.technicalDetails ?? 'N/A'}
Tiempo: ${error.timestamp}
Contexto: ${error.context?.toString() ?? 'N/A'}
''';

    Clipboard.setData(ClipboardData(text: details));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Detalles copiados al portapapeles'), duration: Duration(seconds: 2)));
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day.toString().padLeft(2, '0')}/'
        '${timestamp.month.toString().padLeft(2, '0')}/'
        '${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}
