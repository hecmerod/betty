import 'package:intl/intl.dart';

void main() {
  print('=== Prueba de Formatos de Fecha ===\n');

  final now = DateTime.now();

  // Formato corto - NO requiere inicialización
  print('Formato corto (dd/MM/yyyy HH:mm):');
  try {
    final formatted = DateFormat('dd/MM/yyyy HH:mm').format(now);
    print('✅ $formatted');
  } catch (e) {
    print('❌ Error: $e');
  }

  // Formato largo sin locale - NO requiere inicialización
  print('\nFormato largo sin locale (dd/MM/yyyy - HH:mm:ss):');
  try {
    final formatted = DateFormat('dd/MM/yyyy - HH:mm:ss').format(now);
    print('✅ $formatted');
  } catch (e) {
    print('❌ Error: $e');
  }

  // Formato con locale español - REQUIERE inicialización
  print('\nFormato con locale español (EEEE, dd \'de\' MMMM \'de\' yyyy):');
  try {
    final formatted = DateFormat('EEEE, dd \'de\' MMMM \'de\' yyyy', 'es_ES').format(now);
    print('✅ $formatted');
  } catch (e) {
    print('❌ Error: $e');
    print('   Este formato requiere inicialización de locale');
  }

  print('\n=== Resumen ===');
  print('✅ Los formatos sin locale funcionan correctamente');
  print('❌ Los formatos con locale requieren inicialización');
}
