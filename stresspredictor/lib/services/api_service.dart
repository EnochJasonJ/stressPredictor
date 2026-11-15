import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:stresspredictor/models/health_data.dart';
import 'package:stresspredictor/models/live_multimodal_result.dart';
import 'package:stresspredictor/models/multimodal_prediction.dart';
import 'package:stresspredictor/models/stress_prediction.dart';

/// Service responsible for communicating with the FastAPI backend.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Use 10.0.2.2 for Android emulator → host machine localhost.
  // For a physical device on WiFi, use your machine's actual local IP.
  static const String _baseUrl = 'http://172.16.142.40:8000';

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

  /// Sends one camera JPEG and the app's current physiological values.
  Future<LiveMultimodalResult> analyzeLiveMultimodal(
    Uint8List imageBytes,
    HealthData physiologicalValues,
  ) async {
    if (!physiologicalValues.hasLiveAnalysisInputs) {
      throw ArgumentError(
        'Missing measured or manually entered values: '
        '${physiologicalValues.missingLiveAnalysisInputs.join(', ')}',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/analyze-live-multimodal'),
    );

    request.fields.addAll({
      'snoring_rate': physiologicalValues.snoringRate.toString(),
      'respiration_rate': physiologicalValues.respirationRate.toString(),
      'body_temperature': physiologicalValues.bodyTemperature.toString(),
      'limb_movement_rate': physiologicalValues.limbMovementRate.toString(),
      'blood_oxygen': physiologicalValues.bloodOxygen.toString(),
      'eye_movement': physiologicalValues.eyeMovement.toString(),
      'sleep_hours': physiologicalValues.sleepHours.toString(),
      'heart_rate': physiologicalValues.heartRate.toString(),
    });
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'camera-frame.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    debugPrint('LIVE MULTIMODAL REQUEST STARTED');
    debugPrint('image bytes: ${imageBytes.length}');
    debugPrint('heart_rate: ${request.fields['heart_rate']}');
    debugPrint('blood_oxygen: ${request.fields['blood_oxygen']}');
    debugPrint('respiration_rate: ${request.fields['respiration_rate']}');
    debugPrint('sleep_hours: ${request.fields['sleep_hours']}');
    debugPrint('snoring_rate: ${request.fields['snoring_rate']}');
    debugPrint('body_temperature: ${request.fields['body_temperature']}');
    debugPrint('limb_movement_rate: ${request.fields['limb_movement_rate']}');
    debugPrint('eye_movement: ${request.fields['eye_movement']}');

    final liveClient = http.Client();
    try {
      final streamedResponse = await liveClient
          .send(request)
          .timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(const Duration(seconds: 20));
      debugPrint('LIVE MULTIMODAL RESPONSE: ${response.body}');

      if (response.statusCode != 200) {
        var detail = 'Unknown error';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            detail = decoded['detail']?.toString() ?? detail;
          }
        } on FormatException {
          if (response.body.isNotEmpty) detail = response.body;
        }
        throw Exception(
          'Live analysis failed (${response.statusCode}): $detail',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid live analysis response.');
      }
      return LiveMultimodalResult.fromJson(decoded);
    } catch (error) {
      debugPrint('LIVE MULTIMODAL ERROR: $error');
      if (error is http.ClientException) {
        throw SocketException(error.message);
      }
      rethrow;
    } finally {
      liveClient.close();
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
