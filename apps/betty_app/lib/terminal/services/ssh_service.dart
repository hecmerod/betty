import 'dart:convert';
import '../../shared/services/api_service.dart';

class SshService {
  static final SshService instance = SshService._();
  SshService._();

  final _apiService = ApiService.instance;

  String? _currentSshCommand;

  Future<String> startSsh() async {
    try {
      final response = await _apiService.post('/ssh/start');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'];
        _currentSshCommand = data['command'] as String;
        return _currentSshCommand!;
      } else {
        throw Exception('Error al iniciar SSH: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al iniciar SSH: $e');
    }
  }

  Future<void> stopSsh() async {
    try {
      await _apiService.delete('/ssh/stop');
      _currentSshCommand = null;
    } catch (e) {
      throw Exception('Error al detener SSH: $e');
    }
  }

  String? get currentSshCommand => _currentSshCommand;
}
