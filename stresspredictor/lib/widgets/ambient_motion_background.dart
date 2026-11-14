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
    final sunCenter = Offset(size.width * 0.9, size.height * 0.21 + drift * 24);

    // A quiet sun disc with horizontal cut lines, like a vintage print.
    final sunPaint = Paint()..color = accent.withValues(alpha: 0.16);
    canvas.drawCircle(sunCenter, 52, sunPaint);
    final stripePaint = Paint()
      ..color = background
      ..strokeWidth = 2;
    for (var i = -2; i <= 2; i++) {
      final y = sunCenter.dy + i * 12;
      final halfWidth = math.sqrt(math.max(0, 52 * 52 - (i * 12) * (i * 12)));
      canvas.drawLine(
        Offset(sunCenter.dx - halfWidth, y),
        Offset(sunCenter.dx + halfWidth, y),
        stripePaint,
      );
    }

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink.withValues(alpha: 0.13);
    canvas.save();
    canvas.translate(sunCenter.dx, sunCenter.dy);
    canvas.rotate(phase * math.pi * 2);
    canvas.translate(-sunCenter.dx, -sunCenter.dy);
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
    canvas.restore();

    final orbitAngle = phase * math.pi * 2;
    final orbitDot = Offset(
      sunCenter.dx + math.cos(orbitAngle) * 94,
      sunCenter.dy + math.sin(orbitAngle) * 54,
    );
    canvas.drawCircle(
      orbitDot,
      4,
      Paint()..color = accent.withValues(alpha: 0.72),
    );
    canvas.drawCircle(
      orbitDot,
      9,
      Paint()..color = accent.withValues(alpha: 0.14),
    );

    // A second, slower satellite loop adds depth on the opposite side of the screen.
    final satelliteCenter = Offset(size.width * 0.72, size.height * 0.72);
    final satelliteOrbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accent.withValues(alpha: 0.2);
    canvas.save();
    canvas.translate(satelliteCenter.dx, satelliteCenter.dy);
    canvas.rotate(-phase * math.pi * 2 * 0.65);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 118, height: 44),
      satelliteOrbitPaint,
    );
    canvas.restore();
    final satelliteAngle = -phase * math.pi * 2 * 0.65;
    canvas.drawCircle(
      Offset(
        satelliteCenter.dx + math.cos(satelliteAngle) * 59,
        satelliteCenter.dy + math.sin(satelliteAngle) * 22,
      ),
      3.2,
      Paint()..color = accent.withValues(alpha: 0.8),
    );

    // Two small twinkles breathe at different rates for a little extra life.
    for (final sparkle in [
      Offset(size.width * 0.16, size.height * 0.24),
      Offset(size.width * 0.34, size.height * 0.67),
    ]) {
      final sparklePhase = phase * math.pi * 2 + sparkle.dx * 0.04;
      final sparkleAlpha = 0.18 + (math.sin(sparklePhase) + 1) * 0.18;
      final sparkleSize = 3 + (math.sin(sparklePhase) + 1) * 1.5;
      final sparklePaint = Paint()
        ..color = accent.withValues(alpha: sparkleAlpha)
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(sparkle.dx - sparkleSize, sparkle.dy),
        Offset(sparkle.dx + sparkleSize, sparkle.dy),
        sparklePaint,
      );
      canvas.drawLine(
        Offset(sparkle.dx, sparkle.dy - sparkleSize),
        Offset(sparkle.dx, sparkle.dy + sparkleSize),
        sparklePaint,
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
            0.08 +
            (math.sin(phase * math.pi * 2 + row * 0.5 + column * 0.35) + 1) *
                0.045;
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
