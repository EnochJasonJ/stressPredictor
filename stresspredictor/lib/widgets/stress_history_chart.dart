import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';
import 'package:stresspredictor/models/stress_prediction.dart';
import 'package:stresspredictor/widgets/stress_gauge.dart';

/// Bar chart showing stress levels for the last 7 days.
/// Takes a list of [StressPrediction] (newest first) and groups by day.
class StressHistoryChart extends StatelessWidget {
  const StressHistoryChart({super.key, required this.history});

  final List<StressPrediction> history;

  @override
  Widget build(BuildContext context) {
    final data = _buildDailyData();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Stress Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: history.isEmpty
                  ? const Center(
                      child: Text(
                        'Run your first prediction to see history',
                        style: TextStyle(),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        maxY: 4,
                        minY: 0,
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= data.length) {
                                  return const Text('');
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    data[idx].label,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: data.asMap().entries.map((e) {
                          final color = e.value.avgLevel != null
                              ? stressLevelColor(context, e.value.avgLevel!)
                              : AppColors.surfaceVariant;
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.avgLevel?.toDouble() ?? 0,
                                color: color,
                                width: 14,
                                borderRadius: BorderRadius.circular(4),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 4,
                                  color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                            showingTooltipIndicators: e.value.avgLevel != null ? [0] : [],
                          );
                        }).toList(),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => AppColors.surfaceVariant,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              if (rod.toY == 0) return null;
                              return BarTooltipItem(
                                '${rod.toY.toInt()}',
                                const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<_DailyData> _buildDailyData() {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final labels = ['', 'M', 'T', 'W', 'Th', 'F', 'S', 'S'];

    return days.map((day) {
      final dayPredictions = history.where((p) {
        return p.timestamp.year == day.year &&
            p.timestamp.month == day.month &&
            p.timestamp.day == day.day;
      }).toList();

      final avg = dayPredictions.isEmpty
          ? null
          : (dayPredictions.map((p) => p.stressLevel).reduce((a, b) => a + b) /
                  dayPredictions.length)
              .round();

      return _DailyData(
        label: labels[day.weekday % 7 + 1],
        avgLevel: avg,
      );
    }).toList();
  }
}

class _DailyData {
  final String label;
  final int? avgLevel; // null = no data

  const _DailyData({required this.label, required this.avgLevel});
}
