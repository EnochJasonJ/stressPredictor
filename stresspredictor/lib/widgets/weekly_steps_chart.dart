import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';
import 'package:stresspredictor/services/health_service.dart';

/// A sleek, minimalist bar chart visualizing the last 7 days of Steps.
class WeeklyStepsChart extends StatefulWidget {
  const WeeklyStepsChart({super.key});

  @override
  State<WeeklyStepsChart> createState() => _WeeklyStepsChartState();
}

class _WeeklyStepsChartState extends State<WeeklyStepsChart> {
  List<int>? _stepsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await HealthService.instance.fetchWeeklySteps(days: 7);
    if (mounted) {
      setState(() {
        _stepsData = data; // Data is already sorted oldest-to-newest
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '7-Day Steps Trend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 160,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _stepsData == null || _stepsData!.every((e) => e == 0)
                      ? const Center(
                          child: Text(
                            'No sync data available.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            maxY: _calculateMaxY(_stepsData!),
                            minY: 0,
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final labels = _getLast7DaysLabels();
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= labels.length) return const Text('');
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        labels[idx],
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
                                  reservedSize: 32,
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0) return const SizedBox.shrink();
                                    return Text(
                                      _formatCompact(value),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: _stepsData!.asMap().entries.map((e) {
                              final isToday = e.key == _stepsData!.length - 1;
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value.toDouble(),
                                    color: isToday ? AppColors.primary : AppColors.surfaceVariant,
                                    width: 14,
                                    borderRadius: BorderRadius.circular(4),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: _calculateMaxY(_stepsData!),
                                      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                                showingTooltipIndicators: [0], // Show tooltip constantly?
                              );
                            }).toList(),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (group) => AppColors.surfaceVariant,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
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
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutQuart,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY(List<int> stepData) {
    if (stepData.isEmpty) return 10000;
    final maxVal = stepData.reduce((a, b) => a > b ? a : b);
    if (maxVal < 5000) return 5000;
    // Round to nearest 1000
    return ((maxVal / 1000).ceil() * 1000).toDouble();
  }

  String _formatCompact(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k';
    }
    return value.toInt().toString();
  }

  List<String> _getLast7DaysLabels() {
    final now = DateTime.now();
    final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    // We want the oldest day first (index 0) and today last (index 6)
    final labels = <String>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      if (i == 0) {
        labels.add('Today');
      } else {
        // weekday is 1-7.
        labels.add(weekdays[date.weekday - 1]);
      }
    }
    return labels;
  }
}
