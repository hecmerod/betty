import 'package:flutter/foundation.dart';
import 'dart:async';

import '../../domain/entities/health_data.dart';
import '../../../auth/domain/entities/protected_data.dart';
import '../../application/usecases/get_health_data.dart';
import '../../../auth/application/usecases/get_protected_data.dart';

class HealthMonitorProvider extends ChangeNotifier {
  final GetHealthDataUseCase getHealthDataUseCase;
  final GetProtectedDataUseCase getProtectedDataUseCase;

  HealthMonitorProvider({
    required this.getHealthDataUseCase,
    required this.getProtectedDataUseCase,
  });

  // Health Data State
  HealthData? _healthData;
  bool _isHealthLoading = false;
  String? _healthError;
  Timer? _refreshTimer;

  // Protected Data State
  ProtectedData? _protectedData;
  bool _isProtectedLoading = false;
  String? _protectedError;

  // Getters
  HealthData? get healthData => _healthData;
  bool get isHealthLoading => _isHealthLoading;
  String? get healthError => _healthError;

  ProtectedData? get protectedData => _protectedData;
  bool get isProtectedLoading => _isProtectedLoading;
  String? get protectedError => _protectedError;

  // Public Methods
  Future<void> fetchHealthData() async {
    _isHealthLoading = true;
    _healthError = null;
    notifyListeners();

    try {
      _healthData = await getHealthDataUseCase();
      _healthError = null;
    } catch (e) {
      _healthError = e.toString();
      _healthData = null;
    } finally {
      _isHealthLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProtectedData() async {
    _isProtectedLoading = true;
    _protectedError = null;
    notifyListeners();

    try {
      _protectedData = await getProtectedDataUseCase();
      _protectedError = null;
    } catch (e) {
      _protectedError = e.toString();
      _protectedData = null;
    } finally {
      _isProtectedLoading = false;
      notifyListeners();
    }
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 10)}) {
    _refreshTimer?.cancel();
    fetchHealthData(); // Fetch immediately
    _refreshTimer = Timer.periodic(interval, (_) => fetchHealthData());
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
