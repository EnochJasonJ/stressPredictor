import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stresspredictor/models/health_data.dart';
import 'package:stresspredictor/models/stress_prediction.dart';

/// Service responsible for communicating with the FastAPI backend.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Use 10.0.2.2 for Android emulator → host machine localhost.
  // For a physical device on WiFi, use your machine's actual local IP.
  static const String _baseUrl = 'http://192.168.0.103:8000';

  final _client = http.Client();

  /// POST /predict – sends [HealthData] and returns a [StressPrediction].
  Future<StressPrediction> predict(HealthData data) async {
    final uri = Uri.parse('$_baseUrl/predict');

    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data.toJson()),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return StressPrediction(
          stressLevel: json['stress_level'] as int,
          stressLabel: json['stress_label'] as String,
          timestamp: DateTime.now(),
        );
      } else {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(
            'Prediction failed (${response.statusCode}): ${json['detail'] ?? 'Unknown error'}');
      }
    } on Exception {
      rethrow;
    }
  }

  /// GET /health – checks if the API server is reachable.
  Future<bool> isHealthy() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
