import "dart:math" as math;
import "package:flutter/material.dart";
import "../theme.dart";

class BalanceRing extends StatelessWidget {
  final double size;
  final double yours;
  final double vat;
  final double tax;

  const BalanceRing({
    super.key,
    required this.size,
    required this.yours,
    required this.vat,
    required this.tax,
  });

  @override
  Widget build(BuildContext context) {
    final total = (yours + vat + tax).clamp(0.001, double.infinity);
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size.square(size),
          painter: _RingPainter(
            segments: [
              _Seg(value: yours / total, color: ForemanColors.teal),
              _Seg(value: vat / total,   color: ForemanColors.amber),
              _Seg(value: tax / total,   color: ForemanColors.green),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Yours", style: TextStyle(color: ForemanColors.white, fontSize: 14)),
            Text(
              "£${yours.toStringAsFixed(0)}",
              style: const TextStyle(color: ForemanColors.white, fontWeight: FontWeight.w800, fontSize: 26),
            ),
          ],
        ),
      ],
    );
  }
}

class _Seg { final double value; final Color color; const _Seg({required this.value, required this.color}); }

class _RingPainter extends CustomPainter {
  final List<_Seg> segments;
  _RingPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width/2 - 8;
    const thickness = 18.0;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = ForemanColors.white.withValues(alpha: 0.10)
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);

    double start = -math.pi/2;
    for (final s in segments) {
      final sweep = 2*math.pi * s.value;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..color = s.color
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, p);
      start += sweep + 0.03; // small gap between slices
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.segments != segments;
}

