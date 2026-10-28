import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ArcSlider extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final ValueChanged<double> onChanged;
  final String label;
  final String displayValue;
  final List<Color> gradientColors;
  final double size;

  const ArcSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.displayValue,
    required this.gradientColors,
    this.size = 240,
  });

  @override
  State<ArcSlider> createState() => _ArcSliderState();
}

class _ArcSliderState extends State<ArcSlider> {
  // 240-degree sweep arc: starts at 150 degrees (bottom-left) to 390 degrees (bottom-right)
  static const double _startAngle = 135 * (math.pi / 180);
  static const double _sweepAngle = 270 * (math.pi / 180);

  void _handlePanUpdate(Offset localPos) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;

    var angle = math.atan2(dy, dx);
    if (angle < 0) angle += 2 * math.pi;

    // Normalize relative to _startAngle
    var diff = angle - _startAngle;
    if (diff < 0) diff += 2 * math.pi;

    if (diff <= _sweepAngle) {
      final newValue = (diff / _sweepAngle).clamp(0.0, 1.0);
      widget.onChanged(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        onPanDown: (details) => _handlePanUpdate(details.localPosition),
        onPanUpdate: (details) => _handlePanUpdate(details.localPosition),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _ArcPainter(
                progress: widget.value.clamp(0.0, 1.0),
                startAngle: _startAngle,
                sweepAngle: _sweepAngle,
                gradientColors: widget.gradientColors,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.displayValue,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final double startAngle;
  final double sweepAngle;
  final List<Color> gradientColors;

  _ArcPainter({
    required this.progress,
    required this.startAngle,
    required this.sweepAngle,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 32) / 2;

    // Track Background
    final trackPaint = Paint()
      ..color = const Color(0xFF262C3A)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Active Arc Gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: gradientColors,
        transform: GradientRotation(startAngle),
      ).createShader(rect)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activeSweep = sweepAngle * progress;
    canvas.drawArc(
      rect,
      startAngle,
      activeSweep,
      false,
      activePaint,
    );

    // Knob indicator
    final knobAngle = startAngle + activeSweep;
    final knobX = center.dx + radius * math.cos(knobAngle);
    final knobY = center.dy + radius * math.sin(knobAngle);

    final knobGlow = Paint()
      ..color = gradientColors.last.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(knobX, knobY), 14, knobGlow);

    final knobPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(knobX, knobY), 10, knobPaint);

    final knobCenterPaint = Paint()..color = gradientColors.last;
    canvas.drawCircle(Offset(knobX, knobY), 5, knobCenterPaint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.gradientColors != gradientColors;
  }
}

