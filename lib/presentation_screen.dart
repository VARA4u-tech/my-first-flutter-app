import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class PresentationScreen extends StatelessWidget {
  const PresentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFD8), // Light beige/cream
      body: Stack(
        children: [
          // Background Ducks Floating Continuously
          const Positioned.fill(child: FloatingDucksBackground()),

          // Main Content
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildDesktopLayout(context);
              } else {
                return _buildMobileLayout(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left Side - Duck
        Expanded(
          flex: 5,
          child: Center(
            child: _buildDuckImage(),
          ),
        ),
        // Right Side - Text
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleText(fontSize: 80),
              const SizedBox(height: 20),
              _buildSubtitleText(fontSize: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            // Duck Image
            SizedBox(
              height: 400,
              child: _buildDuckImage(),
            ),
            const SizedBox(height: 40),
            // Text
            _buildTitleText(fontSize: 48, align: TextAlign.center),
            const SizedBox(height: 16),
            _buildSubtitleText(fontSize: 18, align: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildDuckImage() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
      child: SvgPicture.asset(
        'assets/images/duck.svg',
        fit: BoxFit.contain,
        placeholderBuilder: (BuildContext context) => Container(
            padding: const EdgeInsets.all(30.0),
            child: const CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildTitleText({required double fontSize, TextAlign align = TextAlign.left}) {
    return Text(
      'PROJECT\nPRESENTATION',
      textAlign: align,
      style: GoogleFonts.fredoka(
        fontSize: fontSize,
        fontWeight: FontWeight.w700, // Bold
        color: const Color(0xFF1B4D3E), // Dark Green
        height: 1.1,
      ),
    );
  }

  Widget _buildSubtitleText({required double fontSize, TextAlign align = TextAlign.left}) {
    return Text(
      'WWW.REALLYGREATSITE.COM',
      textAlign: align,
      style: GoogleFonts.fredoka(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1B4D3E), // Dark Green
        letterSpacing: 1.5,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Background Animation Components
// ---------------------------------------------------------------------------

class FloatingDucksBackground extends StatefulWidget {
  const FloatingDucksBackground({super.key});

  @override
  State<FloatingDucksBackground> createState() => _FloatingDucksBackgroundState();
}

class _FloatingDucksBackgroundState extends State<FloatingDucksBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  final List<DuckData> _ducks = [];
  final int _duckCount = 20;

  @override
  void initState() {
    super.initState();
    // Initialize random ducks
    final random = math.Random();
    for (int i = 0; i < _duckCount; i++) {
      _ducks.add(DuckData(
        yRel: random.nextDouble(), // 0.0 to 1.0 vertical position
        speed: 30 + random.nextDouble() * 50, // Speed in pixels per second
        scale: 0.5 + random.nextDouble() * 0.8, // Scale variance
        initialOffset: random.nextDouble() * 2000, // Random start X
        bobPhase: random.nextDouble() * 2 * math.pi, // Random bobbing phase
      ));
    }

    _ticker = createTicker((elapsed) {
      if (mounted) {
        setState(() {
          _elapsed = elapsed;
        });
      }
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Don't render if constraints are too small
        if (width <= 0 || height <= 0) return const SizedBox.shrink();

        return Stack(
          children: _ducks.map((duck) {
            double duckSize = 50 * duck.scale;
            double totalPathLength = width + duckSize;
            
            // Calculate X based on time and speed
            // Use inSeconds (double) for smoother math calculation
            double timeSeconds = _elapsed.inMilliseconds / 1000.0;
            
            // Position: (Start + Speed * Time) % Length - Size
            // Subtract duckSize to start off-screen left and end off-screen right
            double currentX = ((duck.initialOffset + timeSeconds * duck.speed) % totalPathLength) - duckSize;
            
            // Calculate Y with bobbing
            double bob = math.sin((timeSeconds * 2) + duck.bobPhase) * 8;
            double currentY = (duck.yRel * (height - duckSize)) + bob;

            return Positioned(
              left: currentX,
              top: currentY,
              child: Opacity(
                opacity: 0.25, // Subtle background opacity
                child: Transform.scale(
                  scale: duck.scale,
                  child: SvgPicture.asset(
                    'assets/images/duck.svg',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class DuckData {
  final double yRel;
  final double speed;
  final double scale;
  final double initialOffset;
  final double bobPhase;

  DuckData({
    required this.yRel,
    required this.speed,
    required this.scale,
    required this.initialOffset,
    required this.bobPhase,
  });
}
