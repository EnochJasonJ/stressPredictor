import 'package:flutter/foundation.dart';
import 'package:stresspredictor/models/health_data.dart';
import 'package:stresspredictor/models/stress_prediction.dart';
import 'package:stresspredictor/services/api_service.dart';
import 'package:stresspredictor/services/health_service.dart';
import 'package:stresspredictor/services/local_storage_service.dart';

/// Manages all state related to stress predictions.
class StressProvider extends ChangeNotifier {
  bool _isLoading = false;
  StressPrediction? _currentPrediction;
  List<StressPrediction> _history = [];
  String? _error;
  HealthData? _currentHealthData;
  bool _healthPermissionGranted = false;

  bool get isLoading => _isLoading;
  StressPrediction? get currentPrediction => _currentPrediction;
  List<StressPrediction> get history => List.unmodifiable(_history);
  String? get error => _error;
  HealthData? get currentHealthData => _currentHealthData;
  bool get healthPermissionGranted => _healthPermissionGranted;

  /// Loads persisted history from local storage and silently refreshes live health data.
  Future<void> loadHistory() async {
    _history = await LocalStorageService.instance.loadHistory();
    if (_history.isNotEmpty) {
      _currentPrediction = _history.first;
    }
    notifyListeners();
    _refreshHealthDataSilently();
  }

  /// Fetches fresh health data in the background without causing loading spinners.
  Future<void> _refreshHealthDataSilently() async {
    try {
      final healthData = await HealthService.instance.fetchHealthData();
      _currentHealthData = healthData;
      // We assume authorized if data fetch did not throw
      _healthPermissionGranted = true;
      notifyListeners();
    } catch (_) {
      // Fail silently for background refresh
    }
  }

  /// Fetches health data automatically and runs the prediction.
  Future<void> predictFromHealthData() async {
    _setLoading(true);
    try {
      final healthData = await HealthService.instance.fetchHealthData();
      _currentHealthData = healthData;
      await _runPrediction(healthData);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Runs prediction with manually provided [HealthData].
  Future<void> predictFromManualData(HealthData data) async {
    _setLoading(true);
    try {
      _currentHealthData = data;
      await _runPrediction(data);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _runPrediction(HealthData data) async {
    _error = null;
    final prediction = await ApiService.instance.predict(data);
    _currentPrediction = prediction;
    _history.insert(0, prediction);
    await LocalStorageService.instance.saveHistory(_history);
    notifyListeners();
  }

  /// Clears all saved stress predictions from history.
  Future<void> clearPredictionHistory() async {
    _history.clear();
    _currentPrediction = null;
    await LocalStorageService.instance.saveHistory([]);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
