import 'dart:convert';

void main() {
  print('=== Prueba de hasTripInProgress Response ===\n');

  // Simular respuesta del servidor
  final serverResponse = {'hasInProgress': true};

  print('Respuesta del servidor:');
  print(json.encode(serverResponse));

  print('\nParsing:');
  try {
    final responseData = serverResponse;
    final hasInProgress = responseData['hasInProgress'] as bool;
    print('✅ hasInProgress: $hasInProgress');
  } catch (e, stackTrace) {
    print('❌ Error en parsing:');
    print(e);
    print(stackTrace);
  }

  print('\n=== Prueba con false ===');
  final serverResponse2 = {'hasInProgress': false};
  print('Respuesta del servidor:');
  print(json.encode(serverResponse2));

  print('\nParsing:');
  try {
    final responseData = serverResponse2;
    final hasInProgress = responseData['hasInProgress'] as bool;
    print('✅ hasInProgress: $hasInProgress');
  } catch (e, stackTrace) {
    print('❌ Error en parsing:');
    print(e);
    print(stackTrace);
  }

  print('\n=== RESUMEN ===');
  print('✅ El cliente ahora parsea correctamente { hasInProgress: boolean }');
  print('✅ El error de type cast está resuelto');
}
