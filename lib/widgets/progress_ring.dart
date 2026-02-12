import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Widget child;

  const ProgressRing({
    Key? key,
    required this.progress,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track ring
          CustomPaint(
            size: const Size(180, 180),
            painter: _RingPainter(
              progress: 1.0,
              color: Colors.grey.shade200,
              strokeWidth: 10,
            ),
          ),
          // Animated progress ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return CustomPaint(
                size: const Size(180, 180),
                painter: _RingPainter(
                  progress: value,
                  color: _getColor(value),
                  strokeWidth: 10,
                ),
              );
            },
          ),
          // Child (the duck)
          child,
        ],
      ),
    );
  }

  Color _getColor(double value) {
    if (value >= 1.0) return const Color(0xFF4CAF50); // Green — all done!
    if (value > 0.6) return AppTheme.primaryGreen;
    if (value > 0.3) return AppTheme.accentYellow;
    return AppTheme.priorityHigh;
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start from top (−π/2)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
