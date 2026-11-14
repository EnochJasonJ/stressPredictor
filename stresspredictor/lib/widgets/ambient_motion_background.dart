import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Slow, low-contrast analog-inspired motion for the dashboard backdrop.
class AmbientMotionBackground extends StatefulWidget {
  const AmbientMotionBackground({super.key});

  @override
  State<AmbientMotionBackground> createState() =>
      _AmbientMotionBackgroundState();
}

class _AmbientMotionBackgroundState extends State<AmbientMotionBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reducedMotion) return;
    _reducedMotion = reduceMotion;
    if (reduceMotion) {
      _controller.stop();
      _controller.value = 0;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _AmbientPainter(
              phase: _reducedMotion == true ? 0 : _controller.value,
              ink: scheme.primary,
              accent: scheme.secondary,
              background: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter({
    required this.phase,
    required this.ink,
    required this.accent,
    required this.background,
  });

  final double phase;
  final Color ink;
  final Color accent;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final drift = math.sin(phase * math.pi * 2);
    final sunCenter = Offset(size.width * 0.91, size.height * 0.2 + drift * 11);

    // A quiet sun disc with horizontal cut lines, like a vintage print.
    final sunPaint = Paint()..color = accent.withValues(alpha: 0.055);
    canvas.drawCircle(sunCenter, 47, sunPaint);
    final stripePaint = Paint()
      ..color = background
      ..strokeWidth = 2;
    for (var i = -2; i <= 2; i++) {
      final y = sunCenter.dy + i * 11;
      final halfWidth = math.sqrt(math.max(0, 47 * 47 - (i * 11) * (i * 11)));
      canvas.drawLine(
        Offset(sunCenter.dx - halfWidth, y),
        Offset(sunCenter.dx + halfWidth, y),
        stripePaint,
      );
    }

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink.withValues(alpha: 0.055);
    for (var i = 0; i < 4; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: sunCenter,
          width: 130 + i * 38,
          height: 74 + i * 22,
        ),
        orbitPaint,
      );
    }

    // Sparse halftone dots fade in and out very gently across the lower edge.
    final dotPaint = Paint();
    for (var row = 0; row < 7; row++) {
      for (var column = 0; column < 8; column++) {
        final x = 20 + column * 13.0;
        final y = size.height * 0.84 + row * 13.0;
        if (x > size.width * 0.45 || y > size.height) continue;
        final pulse =
            0.035 +
            (math.sin(phase * math.pi * 2 + row * 0.5 + column * 0.35) + 1) *
                0.012;
        dotPaint.color = ink.withValues(alpha: pulse);
        canvas.drawCircle(Offset(x, y), 1.15, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.ink != ink ||
      oldDelegate.accent != accent ||
      oldDelegate.background != background;
}
