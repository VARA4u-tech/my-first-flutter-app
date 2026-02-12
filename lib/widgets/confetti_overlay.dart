import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A lightweight confetti overlay — no external packages needed.
class ConfettiOverlay extends StatefulWidget {
  final bool trigger; // set to true to fire confetti

  const ConfettiOverlay({Key? key, required this.trigger}) : super(key: key);

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_ConfettiParticle> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Fire when trigger goes from false → true
    if (widget.trigger && !oldWidget.trigger) {
      _fireConfetti();
    }
  }

  void _fireConfetti() {
    _particles = List.generate(60, (_) {
      return _ConfettiParticle(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.3,
        velocityX: (_random.nextDouble() - 0.5) * 0.4,
        velocityY: 0.3 + _random.nextDouble() * 0.5,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 6,
        size: 6 + _random.nextDouble() * 8,
        color: _confettiColors[_random.nextInt(_confettiColors.length)],
      );
    });
    _controller.forward(from: 0);
  }

  static const _confettiColors = [
    Color(0xFFFF6B6B), // Red
    Color(0xFFFFD93D), // Yellow
    Color(0xFF6BCB77), // Green
    Color(0xFF4D96FF), // Blue
    Color(0xFFFF6BD6), // Pink
    Color(0xFFFF9F43), // Orange
    Color(0xFFA66CFF), // Purple
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isAnimating && _particles.isEmpty) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(
          particles: _particles,
          progress: _controller.value,
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  double x, y, velocityX, velocityY, rotation, rotationSpeed, size;
  Color color;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final t = progress;
      final gravity = 0.3 * t * t; // acceleration
      final currentX = (p.x + p.velocityX * t) * size.width;
      final currentY = (p.y + p.velocityY * t + gravity) * size.height;
      final rotation = p.rotation + p.rotationSpeed * t;
      final opacity = (1.0 - t).clamp(0.0, 1.0);

      if (currentY > size.height + 20) continue;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(rotation);

      final paint = Paint()..color = p.color.withOpacity(opacity);
      // Draw a small rectangle as confetti piece
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
