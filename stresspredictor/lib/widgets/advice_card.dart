import 'package:flutter/material.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';
import 'package:stresspredictor/widgets/stress_gauge.dart';

/// Data-driven advice content for each stress level.
const _adviceData = [
  _AdviceData(
    icon: Icons.spa_outlined,
    iconColor: AppColors.stressLow,
    title: 'Excellent! You\'re very relaxed.',
    body:
        'Your stress indicators look great. Keep up your healthy habits — good sleep, regular movement, and balanced nutrition.',
  ),
  _AdviceData(
    icon: Icons.self_improvement_outlined,
    iconColor: AppColors.secondary,
    title: 'Low stress detected.',
    body:
        'You\'re in a good place. Consider a short mindfulness session or a walk outside to keep stress at bay.',
  ),
  _AdviceData(
    icon: Icons.air_outlined,
    iconColor: AppColors.stressMedium,
    title: 'Moderate stress levels.',
    body:
        'Try box breathing (4-4-4-4) or progressive muscle relaxation. Aim for 7–9 hours of sleep tonight.',
  ),
  _AdviceData(
    icon: Icons.warning_amber_outlined,
    iconColor: AppColors.accent,
    title: 'High stress detected.',
    body:
        'Take a break now. 10 minutes of deep breathing or light stretching can significantly reduce cortisol. Limit caffeine and screen time.',
  ),
  _AdviceData(
    icon: Icons.favorite_border,
    iconColor: AppColors.stressHigh,
    title: 'Very high stress — take action!',
    body:
        'Your body needs rest. Step away from stressors, drink water, and try a 20-minute guided meditation. If this persists, consider speaking to a professional.',
  ),
];

class _AdviceData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  const _AdviceData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });
}

/// Card showing AI-generated stress advice based on the predicted level.
class AdviceCard extends StatelessWidget {
  const AdviceCard({super.key, required this.stressLevel});

  final int stressLevel;

  @override
  Widget build(BuildContext context) {
    final level = stressLevel.clamp(0, 4);
    final data = _adviceData[level];
    final color = stressLevelColor(context, level);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: data.iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: data.iconColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              data.body,
              style: const TextStyle(
                fontSize: 13,
                
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
