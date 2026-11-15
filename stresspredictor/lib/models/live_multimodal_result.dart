/// Response from POST /analyze-live-multimodal.
class LiveMultimodalResult {
  const LiveMultimodalResult({
    required this.physiologicalStress,
    required this.vision,
    required this.finalStress,
    this.analysisStatus,
  });

  final LiveStressValue physiologicalStress;
  final LiveVisionResult vision;
  final LiveStressValue finalStress;
  final String? analysisStatus;

  factory LiveMultimodalResult.fromJson(Map<String, dynamic> json) {
    return LiveMultimodalResult(
      physiologicalStress: LiveStressValue.fromJson(
        _requiredMap(json['physiological_stress'], 'physiological_stress'),
      ),
      vision: LiveVisionResult.fromJson(_requiredMap(json['vision'], 'vision')),
      finalStress: LiveStressValue.fromJson(
        _requiredMap(json['final_stress'], 'final_stress'),
      ),
      analysisStatus: json['analysis_status'] as String?,
    );
  }

  static Map<String, dynamic> _requiredMap(Object? value, String field) {
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Missing or invalid "$field" response object.');
  }
}

class LiveStressValue {
  const LiveStressValue({required this.level, required this.label});

  final int level;
  final String label;

  factory LiveStressValue.fromJson(Map<String, dynamic> json) {
    final level = json['level'];
    final label = json['label'];
    if (level is! num || label is! String) {
      throw const FormatException('Invalid stress level response.');
    }
    return LiveStressValue(level: level.toInt(), label: label);
  }
}

class LiveVisionResult {
  const LiveVisionResult({
    required this.faceDetected,
    required this.framesAnalyzed,
    required this.windowSeconds,
    required this.averageEar,
    required this.closedEyeRatio,
    required this.longestEyeClosure,
    required this.fatigueIndicator,
    required this.dominantExpression,
    required this.expressionStability,
  });

  final bool faceDetected;
  final int framesAnalyzed;
  final double? windowSeconds;
  final double? averageEar;
  final double? closedEyeRatio;
  final double? longestEyeClosure;
  final String? fatigueIndicator;
  final String? dominantExpression;
  final double? expressionStability;

  factory LiveVisionResult.fromJson(Map<String, dynamic> json) {
    final faceDetected = json['face_detected'];
    if (faceDetected is! bool) {
      throw const FormatException('Invalid face_detected response value.');
    }

    return LiveVisionResult(
      faceDetected: faceDetected,
      framesAnalyzed: _asInt(json['frames_analyzed']) ?? 0,
      windowSeconds: _asDouble(json['window_seconds']),
      averageEar: _asDouble(json['average_ear']),
      closedEyeRatio: _asDouble(json['closed_eye_ratio']),
      longestEyeClosure: _asDouble(json['longest_eye_closure']),
      fatigueIndicator: json['fatigue_indicator'] as String?,
      dominantExpression: json['dominant_expression'] as String?,
      expressionStability: _asDouble(json['expression_stability']),
    );
  }

  static int? _asInt(Object? value) => value is num ? value.toInt() : null;
  static double? _asDouble(Object? value) =>
      value is num ? value.toDouble() : null;
}
