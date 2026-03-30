import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';

/// Returns the appropriate color for a stress level (0–4).
Color stressLevelColor(BuildContext context, int level) {
  switch (level) {
    case 0:
      return AppColors.stressLow;
    case 1:
      return AppColors.secondary;
    case 2:
      return AppColors.stressMedium;
    case 3:
      return AppColors.accent;
    case 4:
      return AppColors.stressHigh;
    default:
      return Theme.of(context).hintColor;
  }
}

/// Animated circular gauge that visualises a stress level (0–4).
class StressGauge extends StatefulWidget {
  const StressGauge({
    super.key,
    required this.stressLevel,
    required this.stressLabel,
  });

  final int stressLevel;
  final String stressLabel;

  @override
  State<StressGauge> createState() => _StressGaugeState();
}

class _StressGaugeState extends State<StressGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _animation = Tween<double>(begin: 0, end: widget.stressLevel / 4.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(StressGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stressLevel != widget.stressLevel) {
      _animation = Tween<double>(
        begin: oldWidget.stressLevel / 4.0,
        end: widget.stressLevel / 4.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = stressLevelColor(context, widget.stressLevel);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _GaugePainter(
                  progress: _animation.value,
                  color: color,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(widget.stressLevel / 4 * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        widget.stressLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final bgPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.color != color;
}
