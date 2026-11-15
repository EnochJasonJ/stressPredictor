class HealthData {
  final double snoringRate;
  final double respirationRate;
  final double bodyTemperature;
  final int steps;
  final int calories;
  final double limbMovementRate;
  final double bloodOxygen;
  final double eyeMovement;
  final double sleepHours;
  final double heartRate;

  // Provenance — which fields came from a real sensor vs smart estimate
  final bool heartRateFromSensor;
  final bool bloodOxygenFromSensor;
  final bool sleepFromSensor;
  final bool respirationFromSensor;
  final bool bodyTemperatureFromSensor;
  final bool snoringRateManuallyProvided;
  final bool respirationRateManuallyProvided;
  final bool bodyTemperatureManuallyProvided;
  final bool limbMovementRateManuallyProvided;
  final bool bloodOxygenManuallyProvided;
  final bool eyeMovementManuallyProvided;
  final bool sleepHoursManuallyProvided;
  final bool heartRateManuallyProvided;

  const HealthData({
    required this.snoringRate,
    required this.respirationRate,
    required this.bodyTemperature,
    required this.steps,
    required this.calories,
    required this.limbMovementRate,
    required this.bloodOxygen,
    required this.eyeMovement,
    required this.sleepHours,
    required this.heartRate,
    this.heartRateFromSensor = false,
    this.bloodOxygenFromSensor = false,
    this.sleepFromSensor = false,
    this.respirationFromSensor = false,
    this.bodyTemperatureFromSensor = false,
    this.snoringRateManuallyProvided = false,
    this.respirationRateManuallyProvided = false,
    this.bodyTemperatureManuallyProvided = false,
    this.limbMovementRateManuallyProvided = false,
    this.bloodOxygenManuallyProvided = false,
    this.eyeMovementManuallyProvided = false,
    this.sleepHoursManuallyProvided = false,
    this.heartRateManuallyProvided = false,
  });

  factory HealthData.defaults() {
    return HealthData(
      snoringRate: 50.0,
      respirationRate: 18.0,
      bodyTemperature: 98.6,
      steps: 0,
      calories: 0,
      limbMovementRate: 10.0,
      bloodOxygen: 95.0,
      eyeMovement: 80.0,
      sleepHours: 7.0,
      heartRate: 72.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'snoring_rate': snoringRate,
    'respiration_rate': respirationRate,
    'body_temperature': bodyTemperature,
    'steps': steps,
    'calories': calories,
    'limb_movement_rate': limbMovementRate,
    'blood_oxygen': bloodOxygen,
    'eye_movement': eyeMovement,
    'sleep_hours': sleepHours,
    'heart_rate': heartRate,
  };

  /// Required values that have neither sensor provenance nor a manual entry.
  List<String> get missingLiveAnalysisInputs {
    final missing = <String>[];
    if (!snoringRateManuallyProvided) missing.add('Snoring rate');
    if (!respirationFromSensor && !respirationRateManuallyProvided) {
      missing.add('Respiration rate');
    }
    if (!bodyTemperatureFromSensor && !bodyTemperatureManuallyProvided) {
      missing.add('Body temperature');
    }
    if (!limbMovementRateManuallyProvided) missing.add('Limb movement rate');
    if (!bloodOxygenFromSensor && !bloodOxygenManuallyProvided) {
      missing.add('Blood oxygen');
    }
    if (!eyeMovementManuallyProvided) missing.add('Eye movement');
    if (!sleepFromSensor && !sleepHoursManuallyProvided) {
      missing.add('Sleep hours');
    }
    if (!heartRateFromSensor && !heartRateManuallyProvided) {
      missing.add('Heart rate');
    }
    return missing;
  }

  bool get hasLiveAnalysisInputs => missingLiveAnalysisInputs.isEmpty;

  HealthData copyWith({
    double? snoringRate,
    double? respirationRate,
    double? bodyTemperature,
    int? steps,
    int? calories,
    double? limbMovementRate,
    double? bloodOxygen,
    double? eyeMovement,
    double? sleepHours,
    double? heartRate,
  }) {
    return HealthData(
      snoringRate: snoringRate ?? this.snoringRate,
      respirationRate: respirationRate ?? this.respirationRate,
      bodyTemperature: bodyTemperature ?? this.bodyTemperature,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      limbMovementRate: limbMovementRate ?? this.limbMovementRate,
      bloodOxygen: bloodOxygen ?? this.bloodOxygen,
      eyeMovement: eyeMovement ?? this.eyeMovement,
      sleepHours: sleepHours ?? this.sleepHours,
      heartRate: heartRate ?? this.heartRate,
      heartRateFromSensor: heartRateFromSensor,
      bloodOxygenFromSensor: bloodOxygenFromSensor,
      sleepFromSensor: sleepFromSensor,
      respirationFromSensor: respirationFromSensor,
      bodyTemperatureFromSensor: bodyTemperatureFromSensor,
      snoringRateManuallyProvided:
          snoringRate != null || snoringRateManuallyProvided,
      respirationRateManuallyProvided:
          respirationRate != null || respirationRateManuallyProvided,
      bodyTemperatureManuallyProvided:
          bodyTemperature != null || bodyTemperatureManuallyProvided,
      limbMovementRateManuallyProvided:
          limbMovementRate != null || limbMovementRateManuallyProvided,
      bloodOxygenManuallyProvided:
          bloodOxygen != null || bloodOxygenManuallyProvided,
      eyeMovementManuallyProvided:
          eyeMovement != null || eyeMovementManuallyProvided,
      sleepHoursManuallyProvided:
          sleepHours != null || sleepHoursManuallyProvided,
      heartRateManuallyProvided: heartRate != null || heartRateManuallyProvided,
    );
  }
}
