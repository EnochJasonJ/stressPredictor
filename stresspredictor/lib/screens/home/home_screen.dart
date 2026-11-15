import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stresspredictor/core/constants/app_constants.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';
import 'package:stresspredictor/providers/stress_provider.dart';
import 'package:stresspredictor/widgets/activity_card.dart';
import 'package:stresspredictor/widgets/ambient_motion_background.dart';
import 'package:stresspredictor/widgets/advice_card.dart';
import 'package:stresspredictor/widgets/stress_gauge.dart';
import 'package:stresspredictor/widgets/stress_history_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StressProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Widget _enter(Widget child, double start, double end) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.045),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
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
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientMotionBackground()),
          SafeArea(
            child: Consumer<StressProvider>(
              builder: (context, provider, _) => RefreshIndicator(
                color: Theme.of(context).colorScheme.primary,
                onRefresh: provider.predictFromHealthData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _enter(
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Icon(
                                    Icons.graphic_eq_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Text(
                                  'FIELDNOTE',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        letterSpacing: 1.7,
                                      ),
                                ),
                                const Spacer(),
                                Text(
                                  '${months[now.month - 1]} ${now.day}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                _HeaderAction(
                                  icon: Icons.camera_alt_outlined,
                                  tooltip: 'Live stress analysis',
                                  onTap: () => context.push(
                                    AppConstants.liveAnalysisPath,
                                    extra: provider.currentHealthData,
                                  ),
                                ),
                                _HeaderAction(
                                  icon: Icons.tune_rounded,
                                  tooltip: 'Manual prediction',
                                  onTap: () =>
                                      context.push(AppConstants.predictPath),
                                ),
                              ],
                            ),
                            0,
                            0.42,
                          ),
                          const SizedBox(height: 28),
                          _enter(
                            Text(
                              'A moment for\nyourself.',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(fontSize: 34, height: 1.08),
                            ),
                            0.08,
                            0.5,
                          ),
                          const SizedBox(height: 8),
                          _enter(
                            Text(
                              'Your wellbeing, in focus.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            0.14,
                            0.56,
                          ),
                          const SizedBox(height: 22),
                          _enter(_StressPanel(provider: provider), 0.2, 0.62),
                          const SizedBox(height: 14),
                          _enter(
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: provider.isLoading
                                    ? null
                                    : provider.predictFromHealthData,
                                icon: provider.isLoading
                                    ? SizedBox(
                                        width: 17,
                                        height: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
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
                            0.28,
                            0.7,
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
                                    icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                    ),
                                    tooltip: 'View health data',
                                  ),
                          ),
                          const SizedBox(height: 8),
                          _enter(
                            ActivityCard(
                              healthData: provider.currentHealthData,
                            ),
                            0.4,
                            0.82,
                          ),
                          if (provider.currentPrediction != null) ...[
                            const SizedBox(height: 26),
                            const _SectionHeading(
                              eyebrow: 'A LITTLE GUIDANCE',
                              title: 'Try this next',
                            ),
                            const SizedBox(height: 8),
                            _enter(
                              AdviceCard(
                                stressLevel:
                                    provider.currentPrediction!.stressLevel,
                              ),
                              0.5,
                              0.92,
                            ),
                          ],
                          const SizedBox(height: 26),
                          _SectionHeading(
                            eyebrow: 'THE LAST 7 DAYS',
                            title: 'Your rhythm',
                            trailing: Text(
                              '${provider.history.length} LOGS',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _enter(
                            StressHistoryChart(history: provider.history),
                            0.58,
                            1,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Small steps count. Keep checking in.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
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
        ],
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
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
