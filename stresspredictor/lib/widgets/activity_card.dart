import 'package:flutter/material.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';
import 'package:stresspredictor/models/health_data.dart';

/// Minimalist widget displaying real imported Google Fit metrics.
class ActivityCard extends StatelessWidget {
  final HealthData? healthData;

  const ActivityCard({super.key, required this.healthData});

  @override
  Widget build(BuildContext context) {
    if (healthData == null || (healthData!.steps == 0 && healthData!.calories == 0)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Connect Sync',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetric(
                icon: Icons.directions_walk_rounded,
                label: 'Steps Today',
                value: healthData!.steps.toString(),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetric(
                icon: Icons.local_fire_department_rounded,
                label: 'Energy Burned',
                value: '${healthData!.calories} kcal',
                color: AppColors.stressMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
