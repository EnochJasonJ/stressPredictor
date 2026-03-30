import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';
import 'package:stresspredictor/models/health_data.dart';
import 'package:stresspredictor/providers/stress_provider.dart';
import 'package:stresspredictor/services/health_service.dart';

/// Manual input screen – lets users enter (or adjust) all 8 health features
/// before running a stress prediction. Pre-populated from Health Connect
/// where data is available.
class PredictScreen extends StatefulWidget {
  const PredictScreen({super.key});

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  bool _isFetching = true;
  late HealthData _data;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    final data = await HealthService.instance.fetchHealthData();
    if (mounted) {
      setState(() {
        _data = data;
        _isFetching = false;
      });
    }
  }

  void _updateField(String field, double value) {
    setState(() {
      _data = switch (field) {
        'snoring' => _data.copyWith(snoringRate: value),
        'respiration' => _data.copyWith(respirationRate: value),
        'temperature' => _data.copyWith(bodyTemperature: value),
        'limb' => _data.copyWith(limbMovementRate: value),
        'oxygen' => _data.copyWith(bloodOxygen: value),
        'eye' => _data.copyWith(eyeMovement: value),
        'sleep' => _data.copyWith(sleepHours: value),
        'heart' => _data.copyWith(heartRate: value),
        _ => _data,
      };
    });
  }

  Future<void> _runPrediction() async {
    final provider = context.read<StressProvider>();
    await provider.predictFromManualData(_data);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Input')),
      body: _isFetching
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Loading health data...',
                    style: TextStyle(),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Adjust Health Metrics',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pre-filled from available sensors. Adjust any values manually.',
                          style: TextStyle(
                            fontSize: 13,
                            
                          ),
                        ),
                        const SizedBox(height: 20),
                        _slider(
                          label: 'Snoring Rate',
                          icon: Icons.bedtime_outlined,
                          value: _data.snoringRate,
                          min: 0,
                          max: 100,
                          unit: '',
                          field: 'snoring',
                        ),
                        _slider(
                          label: 'Respiration Rate',
                          icon: Icons.air_outlined,
                          value: _data.respirationRate,
                          min: 0,
                          max: 60,
                          unit: 'bpm',
                          field: 'respiration',
                        ),
                        _slider(
                          label: 'Body Temperature',
                          icon: Icons.thermostat_outlined,
                          value: _data.bodyTemperature,
                          min: 90,
                          max: 110,
                          unit: '°F',
                          field: 'temperature',
                        ),
                        _slider(
                          label: 'Limb Movement Rate',
                          icon: Icons.accessibility_new_outlined,
                          value: _data.limbMovementRate,
                          min: 0,
                          max: 100,
                          unit: '',
                          field: 'limb',
                        ),
                        _slider(
                          label: 'Blood Oxygen (SpO₂)',
                          icon: Icons.opacity_outlined,
                          value: _data.bloodOxygen,
                          min: 80,
                          max: 100,
                          unit: '%',
                          field: 'oxygen',
                        ),
                        _slider(
                          label: 'Eye Movement',
                          icon: Icons.visibility_outlined,
                          value: _data.eyeMovement,
                          min: 0,
                          max: 100,
                          unit: '',
                          field: 'eye',
                        ),
                        _slider(
                          label: 'Sleep Hours',
                          icon: Icons.hotel_outlined,
                          value: _data.sleepHours,
                          min: 0,
                          max: 24,
                          unit: 'h',
                          field: 'sleep',
                        ),
                        _slider(
                          label: 'Heart Rate',
                          icon: Icons.favorite_border,
                          value: _data.heartRate,
                          min: 30,
                          max: 220,
                          unit: 'bpm',
                          field: 'heart',
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                // ── Predict Button ────────────────────────────────────────
                SafeArea(
                  minimum: const EdgeInsets.only(bottom: 24),
                  child: Consumer<StressProvider>(
                    builder: (context, prov, _) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: prov.isLoading ? null : _runPrediction,
                        icon: prov.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.analytics_outlined),
                        label: Text(
                          prov.isLoading
                              ? 'Predicting...'
                              : 'Predict Stress Level',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ),
              ],
            ),
    );
  }

  Widget _slider({
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required String unit,
    required String field,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${value.toStringAsFixed(1)} $unit',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) * 2).toInt(),
              activeColor: AppColors.primary,
              onChanged: (v) => _updateField(field, v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$min$unit',
                  style: const TextStyle(
                    fontSize: 11,
                    
                  ),
                ),
                Text(
                  '$max$unit',
                  style: const TextStyle(
                    fontSize: 11,
                    
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
