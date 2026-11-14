class MultimodalPrediction {
  final int physiologicalLevel;
  final String physiologicalLabel;
  final String facialExpression;
  final int finalLevel;
  final String finalLabel;
  final DateTime timestamp;

  const MultimodalPrediction({
    required this.physiologicalLevel,
    required this.physiologicalLabel,
    required this.facialExpression,
    required this.finalLevel,
    required this.finalLabel,
    required this.timestamp,
  });

  factory MultimodalPrediction.fromJson(Map<String, dynamic> json) {
    final physiological =
        json['physiological_stress'] as Map<String, dynamic>;

    final finalStress =
        json['final_stress'] as Map<String, dynamic>;

    return MultimodalPrediction(
      physiologicalLevel: physiological['level'] as int,
      physiologicalLabel: physiological['label'] as String,
      facialExpression: json['facial_expression'] as String,
      finalLevel: finalStress['level'] as int,
      finalLabel: finalStress['label'] as String,
      timestamp: DateTime.now(),
    );
  }
}