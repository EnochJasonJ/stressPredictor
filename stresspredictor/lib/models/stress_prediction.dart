/// Data model for a single stress prediction result.
class StressPrediction {
  final int stressLevel;      // 0–4
  final String stressLabel;   // "Very Low" … "Very High"
  final DateTime timestamp;

  const StressPrediction({
    required this.stressLevel,
    required this.stressLabel,
    required this.timestamp,
  });

  /// Percentage score for UI display (0–100).
  double get scorePercent => (stressLevel / 4.0) * 100;

  factory StressPrediction.fromJson(Map<String, dynamic> json) {
    return StressPrediction(
      stressLevel: json['stress_level'] as int,
      stressLabel: json['stress_label'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'stress_level': stressLevel,
        'stress_label': stressLabel,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'StressPrediction(level=$stressLevel, label=$stressLabel, at=$timestamp)';
}
