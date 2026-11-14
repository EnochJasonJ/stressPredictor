import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stresspredictor/core/constants/app_constants.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';
import 'package:stresspredictor/providers/stress_provider.dart';
import 'package:stresspredictor/widgets/activity_card.dart';
import 'package:stresspredictor/widgets/advice_card.dart';
import 'package:stresspredictor/widgets/stress_gauge.dart';
import 'package:stresspredictor/widgets/stress_history_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StressProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return Scaffold(
      body: SafeArea(
        child: Consumer<StressProvider>(
          builder: (context, provider, _) => RefreshIndicator(
            color: AppColors.primary,
            onRefresh: provider.predictFromHealthData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.graphic_eq_rounded,
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Text(
                            'FIELDNOTE',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  letterSpacing: 1.7,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '${months[now.month - 1]} ${now.day}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          _HeaderAction(
                            icon: Icons.tune_rounded,
                            tooltip: 'Manual prediction',
                            onTap: () => context.push(AppConstants.predictPath),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'A moment for\nyourself.',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontSize: 34, height: 1.08),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your wellbeing, in focus.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 22),
                      _StressPanel(provider: provider),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: provider.isLoading
                              ? null
                              : provider.predictFromHealthData,
                          icon: provider.isLoading
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textOnPrimary,
                                  ),
                                )
                              : const Icon(Icons.bolt_rounded, size: 19),
                          label: Text(
                            provider.isLoading
                                ? 'READING YOUR SIGNALS…'
                                : 'CHECK IN WITH MY BODY',
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                          ),
                        ),
                      ),
                      if (provider.error != null) ...[
                        const SizedBox(height: 12),
                        _ErrorNote(
                          message: provider.error!,
                          onDismiss: provider.clearError,
                        ),
                      ],
                      const SizedBox(height: 28),
                      _SectionHeading(
                        eyebrow: 'TODAY',
                        title: 'Body signals',
                        trailing: provider.currentHealthData == null
                            ? null
                            : IconButton(
                                onPressed: () => context.push(
                                  AppConstants.healthDataPath,
                                  extra: provider.currentHealthData,
                                ),
                                icon: const Icon(Icons.arrow_forward_rounded),
                                tooltip: 'View health data',
                              ),
                      ),
                      const SizedBox(height: 8),
                      ActivityCard(healthData: provider.currentHealthData),
                      if (provider.currentPrediction != null) ...[
                        const SizedBox(height: 26),
                        const _SectionHeading(
                          eyebrow: 'A LITTLE GUIDANCE',
                          title: 'Try this next',
                        ),
                        const SizedBox(height: 8),
                        AdviceCard(
                          stressLevel: provider.currentPrediction!.stressLevel,
                        ),
                      ],
                      const SizedBox(height: 26),
                      _SectionHeading(
                        eyebrow: 'THE LAST 7 DAYS',
                        title: 'Your rhythm',
                        trailing: Text(
                          '${provider.history.length} LOGS',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      StressHistoryChart(history: provider.history),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Small steps count. Keep checking in.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StressPanel extends StatelessWidget {
  const _StressPanel({required this.provider});
  final StressProvider provider;

  @override
  Widget build(BuildContext context) {
    final prediction = provider.currentPrediction;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryDark, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'STRESS METER',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.secondaryLight,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              const Icon(Icons.circle, size: 7, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                'LIVE SNAPSHOT',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.75),
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (provider.isLoading)
            const SizedBox(
              height: 172,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.secondaryLight,
                ),
              ),
            )
          else if (prediction == null)
            SizedBox(
              height: 172,
              child: Row(
                children: [
                  const Expanded(
                    child: Icon(
                      Icons.waves_rounded,
                      size: 76,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'No reading yet.\nTake your first check-in to see where you are.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textOnPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 150,
                  height: 160,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: StressGauge(
                      stressLevel: prediction.stressLevel,
                      stressLabel: prediction.stressLabel,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prediction.stressLabel.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.secondaryLight,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${prediction.stressLevel}',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontSize: 45,
                              color: AppColors.textOnPrimary,
                              height: 1,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'out of 4',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textOnPrimary.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 1,
                        color: AppColors.textOnPrimary.withValues(alpha: 0.25),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        '${provider.history.length} check-ins logged',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textOnPrimary.withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 6),
          Text(
            'A guide, not a diagnosis.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    this.trailing,
  });
  final String eyebrow;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.accent,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
      if (trailing != null) trailing!,
    ],
  );
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    tooltip: tooltip,
    style: IconButton.styleFrom(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.divider),
    ),
    icon: Icon(icon, size: 19),
  );
}

class _ErrorNote extends StatelessWidget {
  const _ErrorNote({required this.message, required this.onDismiss});
  final String message;
  final VoidCallback onDismiss;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(13, 8, 8, 8),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: 0.08),
      border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: AppColors.error,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ),
        IconButton(
          onPressed: onDismiss,
          icon: const Icon(Icons.close, size: 17),
          color: AppColors.error,
          visualDensity: VisualDensity.compact,
        ),
      ],
    ),
  );
}
