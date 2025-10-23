class CommandProcessor {
  String processCommand(String command) {
    final parts = command.toLowerCase().split(' ');
    final baseCommand = parts[0];

    switch (baseCommand) {
      case 'help':
        return _helpCommand();

      case 'clear':
        return '';

      default:
        return _unknownCommand(command);
    }
  }

  String _helpCommand() {
    return '''
Comandos disponibles:
  help     - Muestra esta ayuda
  clear    - Limpia el terminal
''';
  }

  String _unknownCommand(String command) {
    return 'Comando no reconocido: "$command". Escribe "help" para ver los comandos disponibles.';
  }
}
