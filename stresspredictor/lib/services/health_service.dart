import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:stresspredictor/models/health_data.dart';

/// Service to interact with Android Health Connect.
/// Fetches required physiological data for stress prediction.
class HealthService {
  HealthService._();
  static final HealthService instance = HealthService._();

  final Health _health = Health();

  /// State flag to track if permissions have been granted.
  bool _isAuthorized = false;

  /// Defines the health data types we need for the model.
  static const List<HealthDataType> _dataTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.STEPS,
    HealthDataType.TOTAL_CALORIES_BURNED,
  ];

  /// The access types requested for the data types above.
  static const List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  Future<bool> initialize() async {
    try {
      await _health.installHealthConnect();

      bool isAvailable = await _health.isHealthConnectAvailable();
      if (!isAvailable) {
        debugPrint("[HealthService] Health Connect not available");
        return false;
      }

      bool? hasPermissions = await _health.hasPermissions(_dataTypes, permissions: _permissions);

      if (hasPermissions != true) {
        bool granted = await _health.requestAuthorization(
          _dataTypes,
          permissions: _permissions,
        );

        if (!granted) {
          debugPrint("[HealthService] User denied Health permissions. Please enable manually in Health Connect app.");
          return false;
        }
      }

      _isAuthorized = true;
      return true;
    } catch (e) {
      debugPrint("[HealthService] Initialization error: $e");
      return false;
    }
  }

  /// Fetches the latest health data.
  Future<HealthData> fetchHealthData() async {
    final defaults = HealthData.defaults();

    if (!_isAuthorized) {
      final authSuccess = await initialize();
      if (!authSuccess) {
        debugPrint("[HealthService] Not authorized, returning defaults.");
        return defaults;
      }
    }

    try {
      final now = DateTime.now();
      // Use local midnight as the start so our "today" exactly matches Google Fit's daily view.
      final midnight = DateTime(now.year, now.month, now.day);

      final healthDataList = await _health.getHealthDataFromTypes(
        types: _dataTypes,
        startTime: midnight,
        endTime: now,
      );

      // Fetch aggregated steps using same midnight-to-now window for consistency.
      int? totalSteps = await _health.getTotalStepsInInterval(midnight, now);

      double? hr;
      double? rr;
      double? temp;
      double? oxygen;
      double? sleepDuration;
      double totalCalories = 0.0;

      healthDataList.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));

      for (var data in healthDataList) {
        final type = data.type;
        final value = data.value;

        double? getValue() {
          if (value is NumericHealthValue) return value.numericValue.toDouble();
          return double.tryParse(value.toString());
        }

        if (type == HealthDataType.HEART_RATE && hr == null) {
          hr = getValue()?.toDouble();
        } else if (type == HealthDataType.RESPIRATORY_RATE && rr == null) {
          rr = getValue()?.toDouble();
        } else if (type == HealthDataType.BODY_TEMPERATURE && temp == null) {
          temp = getValue()?.toDouble();
        } else if (type == HealthDataType.BLOOD_OXYGEN && oxygen == null) {
          oxygen = getValue()?.toDouble();
        } else if (type == HealthDataType.SLEEP_SESSION && sleepDuration == null) {
          // SLEEP_SESSION provides duration via dateTo - dateFrom
          final minutes = data.dateTo.difference(data.dateFrom).inMinutes;
          sleepDuration = minutes / 60.0;
        } else if (type == HealthDataType.TOTAL_CALORIES_BURNED) {
          // Accumulate all calories since midnight
          totalCalories += getValue() ?? 0.0;
        }
      }

      return HealthData(
        snoringRate: defaults.snoringRate,
        respirationRate: rr ?? defaults.respirationRate,
        bodyTemperature: temp ?? defaults.bodyTemperature,
        limbMovementRate: defaults.limbMovementRate,
        bloodOxygen: oxygen ?? defaults.bloodOxygen,
        eyeMovement: defaults.eyeMovement,
        sleepHours: sleepDuration ?? defaults.sleepHours,
        steps: totalSteps ?? 0,
        calories: totalCalories.toInt(),
        heartRate: hr ?? defaults.heartRate,
        // Provenance flags
        heartRateFromSensor: hr != null,
        respirationFromSensor: rr != null,
        bloodOxygenFromSensor: oxygen != null,
        sleepFromSensor: sleepDuration != null,
      );
    } catch (e) {
      debugPrint("[HealthService] Error fetching health data: $e");
      return defaults;
    }
  }

  /// Fetches an array of total steps taken over the last [days] days.
  /// Used primarily for charting health trends.
  Future<List<int>> fetchWeeklySteps({int days = 7}) async {
    if (!_isAuthorized) {
      final authSuccess = await initialize();
      if (!authSuccess) {
        return List.generate(days, (_) => 0);
      }
    }

    try {
      final now = DateTime.now();
      final List<int> dailySteps = [];

      for (int i = days - 1; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final midnight = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

        // Fetch aggregated steps using interval
        int? steps = await _health.getTotalStepsInInterval(
            midnight, i == 0 ? now : endOfDay);
        dailySteps.add(steps ?? 0);
      }

      return dailySteps;
    } catch (e) {
      debugPrint("[HealthService] Error fetching weekly steps: $e");
      return List.generate(days, (_) => 0);
    }
  }
}
