import 'package:flutter/material.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';
import 'package:stresspredictor/models/health_data.dart';

/// Screen that shows a detailed breakdown of all data imported from Google Fit / Health Connect.
class HealthDataScreen extends StatelessWidget {
  final HealthData data;

  const HealthDataScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Health Data')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Synced from Health Connect',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Today\'s Overview',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),

            // --- Activity Section ---
            _sectionHeader(context, 'Activity'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    context,
                    icon: Icons.directions_walk_rounded,
                    label: 'Steps',
                    value: data.steps.toString(),
                    unit: 'steps',
                    color: AppColors.primary,
                    isLive: data.steps > 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metricCard(
                    context,
                    icon: Icons.local_fire_department_rounded,
                    label: 'Calories',
                    value: data.calories.toString(),
                    unit: 'kcal',
                    color: AppColors.stressMedium,
                    isLive: data.calories > 0,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Vitals Section ---
            _sectionHeader(context, 'Vitals'),
            const SizedBox(height: 12),
            _listTile(
              context,
              icon: Icons.favorite_rounded,
              label: 'Heart Rate',
              value: '${data.heartRate.toStringAsFixed(0)} bpm',
              color: AppColors.stressHigh,
              isEstimated: !data.heartRateFromSensor,
            ),
            _listTile(
              context,
              icon: Icons.opacity_rounded,
              label: 'Blood Oxygen (SpO₂)',
              value: '${data.bloodOxygen.toStringAsFixed(1)} %',
              color: AppColors.primary,
              isEstimated: !data.bloodOxygenFromSensor,
            ),
            _listTile(
              context,
              icon: Icons.thermostat_rounded,
              label: 'Body Temperature',
              value: '${data.bodyTemperature.toStringAsFixed(1)} °F',
              color: AppColors.stressMedium,
              isEstimated: true, // Typically derived or manually entered right now
            ),
            _listTile(
              context,
              icon: Icons.air_rounded,
              label: 'Respiration Rate',
              value: '${data.respirationRate.toStringAsFixed(1)} rpm',
              color: Colors.blue,
              isEstimated: !data.respirationFromSensor,
            ),

            const SizedBox(height: 24),

            // --- Sleep Section ---
            _sectionHeader(context, 'Sleep'),
            const SizedBox(height: 12),
            _listTile(
              context,
              icon: Icons.bedtime_rounded,
              label: 'Sleep Duration',
              value: '${data.sleepHours.toStringAsFixed(1)} hrs',
              color: const Color(0xFF9575CD),
              isEstimated: !data.sleepFromSensor,
            ),
            _listTile(
              context,
              icon: Icons.visibility_rounded,
              label: 'Eye Movement',
              value: '${data.eyeMovement.toStringAsFixed(0)} / 100',
              color: AppColors.secondary,
              isEstimated: true, // Our model infers this if not present natively
            ),
            _listTile(
              context,
              icon: Icons.accessibility_new_rounded,
              label: 'Limb Movement',
              value: '${data.limbMovementRate.toStringAsFixed(0)} / 100',
              color: AppColors.secondaryDark,
              isEstimated: true,
            ),
            _listTile(
              context,
              icon: Icons.hearing_rounded,
              label: 'Snoring Rate',
              value: '${data.snoringRate.toStringAsFixed(0)} / 100',
              color: AppColors.stressMedium,
              isEstimated: true,
            ),

            const SizedBox(height: 32),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Values marked as "est." are dynamically estimated from your daily activity trends because your device lacks dedicated sensors for these metrics.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _metricCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
    required bool isLive,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text('Live', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
            Text(
              unit,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isEstimated,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                if (isEstimated) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('est.', style: TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
