import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stresspredictor/core/constants/app_constants.dart';
import 'package:stresspredictor/widgets/ambient_motion_background.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _navigateToHome();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reducedMotion) return;
    _reducedMotion = reduceMotion;
    if (reduceMotion) {
      _pulseController.stop();
      _pulseController.value = 0;
    } else {
      _pulseController.repeat(reverse: true);
    }
  }

  void _navigateToHome() {
    Future.delayed(AppConstants.introDelay, () {
      if (mounted) context.go(AppConstants.homePath);
    });
  }

  void _skipIntro() {
    _entranceController.stop();
    _pulseController.stop();
    context.go(AppConstants.homePath);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Animation<double> _entrance(double start, double end) => CurvedAnimation(
    parent: _entranceController,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
  );

  Widget _riseIn({
    required Widget child,
    required double start,
    required double end,
  }) {
    if (_reducedMotion == true) return child;
    final animation = _entrance(start, end);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.07),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientMotionBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 18),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      'WELLNESS / 01',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _riseIn(
                            start: 0,
                            end: 0.72,
                            child: _buildAnimatedMark(scheme, reduceMotion),
                          ),
                          const SizedBox(height: 34),
                          _riseIn(
                            start: 0.16,
                            end: 0.82,
                            child: Text(
                              AppConstants.appName,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    fontSize: 34,
                                    letterSpacing: -1.2,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _riseIn(
                            start: 0.28,
                            end: 0.95,
                            child: Text(
                              'Your wellness companion',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ),
                          const SizedBox(height: 28),
                          _riseIn(
                            start: 0.38,
                            end: 1,
                            child: _buildSignalIndicator(scheme, reduceMotion),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _riseIn(
                    start: 0.38,
                    end: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'A SMALL PAUSE. A CLEARER SIGNAL.',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 9,
                                  letterSpacing: 1.1,
                                ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _skipIntro,
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                          ),
                          label: const Text('Skip'),
                          style: TextButton.styleFrom(
                            foregroundColor: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMark(ColorScheme scheme, bool reduceMotion) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = reduceMotion ? 0.4 : _pulseController.value;
        final size = 144 + pulse * 16;
        return SizedBox(
          width: 176,
          height: 176,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.primary.withValues(
                      alpha: 0.12 + pulse * 0.12,
                    ),
                    width: 1,
                  ),
                ),
              ),
              Container(
                width: 124 + pulse * 8,
                height: 124 + pulse * 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.secondary.withValues(
                    alpha: 0.08 + pulse * 0.06,
                  ),
                ),
              ),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.2),
                      blurRadius: 28 + pulse * 10,
                      spreadRadius: pulse * 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.graphic_eq_rounded,
                  size: 48,
                  color: scheme.onPrimary,
                ),
              ),
              Positioned(
                right: 17,
                top: 25,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: scheme.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: scheme.secondary.withValues(alpha: 0.42),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSignalIndicator(ColorScheme scheme, bool reduceMotion) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final active =
                reduceMotion || (_pulseController.value * 3).floor() == index;
            return AnimatedContainer(
              duration: Duration(milliseconds: reduceMotion ? 0 : 220),
              curve: Curves.easeOut,
              width: active ? 24 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: active
                    ? scheme.primary
                    : scheme.primary.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        );
      },
    );
  }
}
