import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const BettyApp());
}

class BettyApp extends StatelessWidget {
  const BettyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Betty Health Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B46C1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B46C1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HealthMonitorPage(),
    );
  }
}

class HealthData {
  final String status;
  final String timestamp;
  final double uptime;

  HealthData({
    required this.status,
    required this.timestamp,
    required this.uptime,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      status: json['status'] ?? 'unknown',
      timestamp: json['timestamp'] ?? '',
      uptime: (json['uptime'] ?? 0).toDouble(),
    );
  }

  String get formattedUptime {
    final hours = (uptime / 3600).floor();
    final minutes = ((uptime % 3600) / 60).floor();
    final seconds = (uptime % 60).floor();

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  DateTime get parsedTimestamp {
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return DateTime.now();
    }
  }
}

class HealthMonitorPage extends StatefulWidget {
  const HealthMonitorPage({super.key});

  @override
  State<HealthMonitorPage> createState() => _HealthMonitorPageState();
}

class _HealthMonitorPageState extends State<HealthMonitorPage> {
  static String get _baseUrl =>
      dotenv.env['BETTY_API_BASE_URL'] ?? 'http://localhost:3000/api';
  HealthData? _healthData;
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchHealthData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchHealthData();
    });
  }

  Future<void> _fetchHealthData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _healthData = HealthData.fromJson(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Server responded with status ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor() {
    if (_healthData?.status == 'ok') {
      return Colors.green;
    }
    return Colors.red;
  }

  IconData _getStatusIcon() {
    if (_healthData?.status == 'ok') {
      return Icons.check_circle;
    }
    return Icons.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍓 Betty Health Monitor'),
        backgroundColor: theme.colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _fetchHealthData,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchHealthData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusCard(theme),
              const SizedBox(height: 16),
              if (_healthData != null) ...[
                _buildUptimeCard(theme),
                const SizedBox(height: 16),
                _buildTimestampCard(theme),
              ],
              if (_error != null) _buildErrorCard(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(_getStatusIcon(), size: 64, color: _getStatusColor()),
            const SizedBox(height: 16),
            Text('Server Status', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              _healthData?.status.toUpperCase() ?? 'UNKNOWN',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: _getStatusColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUptimeCard(ThemeData theme) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule, size: 32),
        title: const Text('Uptime'),
        subtitle: Text(_healthData!.formattedUptime),
        trailing: Text(
          '${_healthData!.uptime.toStringAsFixed(1)}s',
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget _buildTimestampCard(ThemeData theme) {
    final timestamp = _healthData!.parsedTimestamp;
    final formattedDate =
        '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final formattedTime =
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.access_time, size: 32),
        title: const Text('Last Updated'),
        subtitle: Text(formattedDate),
        trailing: Text(formattedTime, style: theme.textTheme.bodyLarge),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Connection Error',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure Betty Server is running on ${dotenv.env['BETTY_SERVER_HOST']}:${dotenv.env['BETTY_SERVER_PORT']}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
