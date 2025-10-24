import 'dart:convert';
import 'dart:async';
import 'package:dartssh2/dartssh2.dart';
import '../../shared/services/api_service.dart';

class SshService {
  static final SshService instance = SshService._();
  SshService._();

  final _apiService = ApiService.instance;

  String? _currentSshCommand;
  SSHClient? _sshClient;
  SSHSession? _sshSession;
  String? _host;
  int? _port;
  String? _user;

  bool get isConnected => _sshClient != null;

  /// Inicia el túnel SSH y establece la conexión
  Future<String> startSsh() async {
    try {
      final response = await _apiService.post('/ssh/start');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'];

        _currentSshCommand = data['command'] as String;

        // Parsear el comando SSH para extraer host, port y user
        // Formato: "ssh user@host -p port"
        _parseCommandInfo(_currentSshCommand!);

        // Establecer conexión SSH
        await _connect();

        return _currentSshCommand!;
      } else {
        throw Exception('Error al iniciar SSH: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al iniciar SSH: $e');
    }
  }

  /// Parsea el comando SSH para extraer user, host y port
  void _parseCommandInfo(String command) {
    // Formato esperado: "ssh user@host -p port"
    final regex = RegExp(r'ssh\s+(\w+)@([\w\.]+)\s+-p\s+(\d+)');
    final match = regex.firstMatch(command);

    if (match != null) {
      _user = match.group(1);
      _host = match.group(2);
      _port = int.parse(match.group(3)!);
    } else {
      throw Exception('Formato de comando SSH inválido: $command');
    }
  }

  /// Conecta al servidor SSH
  Future<void> _connect() async {
    if (_host == null || _port == null || _user == null) {
      throw Exception('Datos de conexión SSH no disponibles');
    }

    try {
      final socket = await SSHSocket.connect(_host!, _port!);

      _sshClient = SSHClient(socket, username: _user!, onPasswordRequest: () => 'POLEKREAL2-polekreal2');

      // Crear sesión interactiva
      _sshSession = await _sshClient!.shell(pty: SSHPtyConfig(width: 80, height: 24));
    } catch (e) {
      throw Exception('Error al conectar SSH: $e');
    }
  }

  /// Ejecuta un comando en la sesión SSH
  Future<String> executeCommand(String command) async {
    if (_sshSession == null) {
      throw Exception('No hay sesión SSH activa');
    }

    try {
      final completer = Completer<String>();
      final output = StringBuffer();

      // Escuchar el output
      _sshSession!.stdout.listen(
        (data) {
          final text = utf8.decode(data);
          output.write(text);
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete(output.toString());
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
      );

      // Enviar comando
      _sshSession!.write(utf8.encode('$command\n'));

      // Esperar respuesta con timeout
      return await completer.future.timeout(const Duration(seconds: 10), onTimeout: () => output.toString());
    } catch (e) {
      throw Exception('Error al ejecutar comando: $e');
    }
  }

  /// Stream del output SSH para terminal interactiva
  Stream<String> get outputStream {
    if (_sshSession == null) {
      return Stream.empty();
    }

    return _sshSession!.stdout.map((data) => utf8.decode(data));
  }

  /// Envía input al terminal SSH
  void sendInput(String input) {
    if (_sshSession != null) {
      _sshSession!.write(utf8.encode(input));
    }
  }

  /// Detiene el servidor SSH y cierra la conexión
  Future<void> stopSsh() async {
    try {
      // Cerrar sesión y cliente SSH
      _sshSession?.close();
      _sshClient?.close();

      _sshSession = null;
      _sshClient = null;

      // Llamar al endpoint para detener el túnel
      await _apiService.delete('/ssh/stop');

      _currentSshCommand = null;
      _host = null;
      _port = null;
      _user = null;
    } catch (e) {
      throw Exception('Error al detener SSH: $e');
    }
  }

  String? get currentSshCommand => _currentSshCommand;
}
