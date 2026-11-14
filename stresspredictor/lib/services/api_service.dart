import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:stresspredictor/models/health_data.dart';
import 'package:stresspredictor/models/multimodal_prediction.dart';
import 'package:stresspredictor/models/stress_prediction.dart';

/// Service responsible for communicating with the FastAPI backend.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Use 10.0.2.2 for Android emulator → host machine localhost.
  // For a physical device on WiFi, use your machine's actual local IP.
  static const String _baseUrl = 'http://172.16.142.244:8000';

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
          'Prediction failed (${response.statusCode}): ${json['detail'] ?? 'Unknown error'}',
        );
      }
    } on Exception {
      rethrow;
    }
  }

  Future<MultimodalPrediction> predictMultimodal(
    HealthData data,
    File image,
  ) async {
    final uri = Uri.parse('$_baseUrl/predict-multimodal');

    try {
      final request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'snoring_rate': data.snoringRate.toString(),
        'respiration_rate': data.respirationRate.toString(),
        'body_temperature': data.bodyTemperature.toString(),
        'limb_movement_rate': data.limbMovementRate.toString(),
        'blood_oxygen': data.bloodOxygen.toString(),
        'eye_movement': data.eyeMovement.toString(),
        'sleep_hours': data.sleepHours.toString(),
        'heart_rate': data.heartRate.toString(),
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 45),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        return MultimodalPrediction.fromJson(json);
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      throw Exception(
        'Multimodal prediction failed '
        '(${response.statusCode}): '
        '${json['detail'] ?? 'Unknown error'}',
      );
    } catch (e) {
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
