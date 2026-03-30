import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stresspredictor/core/constants/app_constants.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';
import 'package:stresspredictor/providers/stress_provider.dart';
import 'package:stresspredictor/widgets/advice_card.dart';
import 'package:stresspredictor/widgets/stress_gauge.dart';
import 'package:stresspredictor/widgets/stress_history_chart.dart';
import 'package:stresspredictor/widgets/activity_card.dart';

/// Home / Dashboard screen – shows current stress prediction, advice,
/// weekly history chart, and quick-action buttons.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load persisted history on first open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StressProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Consumer<StressProvider>(
            builder: (context, provider, _) => IconButton(
              icon: const Icon(Icons.monitor_heart_outlined),
              tooltip: 'Health Data',
              onPressed: provider.currentHealthData == null
                  ? null
                  : () => context.push(AppConstants.healthDataPath, extra: provider.currentHealthData),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Manual Input',
            onPressed: () => context.push(AppConstants.predictPath),
          ),
        ],
      ),
      body: Consumer<StressProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: provider.predictFromHealthData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Current Stress Card ─────────────────────────────────
                  _buildStressCard(provider),
                  const SizedBox(height: 20),

                  // ── Analyse Button ──────────────────────────────────────
                  _buildAnalyseButton(provider),
                  // ── Live Google Fit Metrics ─────────────────────────────
                  GestureDetector(
                    onTap: provider.currentHealthData == null
                        ? null
                        : () => context.push(AppConstants.healthDataPath, extra: provider.currentHealthData),
                    child: ActivityCard(healthData: provider.currentHealthData),
                  ),
                  if (provider.currentHealthData != null) const SizedBox(height: 24),

                  // ── Error Banner ────────────────────────────────────────
                  if (provider.error != null) _buildErrorBanner(provider),

                  // ── Advice Card ─────────────────────────────────────────
                  if (provider.currentPrediction != null) ...[
                    const Text(
                      'AI Recommendation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AdviceCard(
                      stressLevel: provider.currentPrediction!.stressLevel,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Weekly Chart ────────────────────────────────────────
                  StressHistoryChart(history: provider.history),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStressCard(StressProvider provider) {
    final prediction = provider.currentPrediction;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Stress Level',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text(
                        'Analysing your health data...',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else if (prediction == null)
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.psychology_outlined,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap "Analyse Stress" to get your\nfirst prediction',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  StressGauge(
                    stressLevel: prediction.stressLevel,
                    stressLabel: prediction.stressLabel,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(
                          Icons.psychology,
                          'Level',
                          '${prediction.stressLevel} / 4',
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          Icons.label_outline,
                          'Category',
                          prediction.stressLabel,
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          Icons.history,
                          'Readings',
                          '${provider.history.length} total',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyseButton(StressProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: provider.isLoading ? null : provider.predictFromHealthData,
        icon: provider.isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.analytics_outlined),
        label: Text(provider.isLoading ? 'Analysing...' : 'Analyse Stress'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }


  Widget _buildErrorBanner(StressProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.error.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  provider.error!,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 13),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    color: AppColors.error, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: provider.clearError,
              ),
            ],
          ),
        ),
      ),
    );
  }
}