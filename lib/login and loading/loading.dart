import 'package:flutter/material.dart';

// --- HOPE LOADING SCREEN WIDGET (FIXED CENTERING) ---

class HopeLoadingScreen extends StatelessWidget {
  const HopeLoadingScreen({super.key});

  static const Gradient hopeGradient = LinearGradient(
    colors: [Color(0xFFFFC107), Color(0xFFFF8F00)],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        // --- NEW LAYOUT USING STACK FOR PERFECT CENTERING ---
        child: Stack(
          children: [
            // 1. The main content, perfectly centered
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Use min size to wrap content
                children: [
                  const PulsingLogo(gradient: hopeGradient),
                  const SizedBox(height: 48),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(text: 'Finding '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GradientText(
                            'Hope',
                            gradient: hopeGradient,
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '"You are stronger than this storm."',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFD1D5DB),
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),

            // 2. The loading indicator, aligned to the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0), // Padding from the bottom
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Important for Align to work correctly
                  children: [
                    const DotPulseLoader(),
                    const SizedBox(height: 16),
                    const Text(
                      'Loading resources...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 1.2,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// --- HELPER WIDGETS (NO CHANGES NEEDED) ---

class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.gradient, this.style});
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style),
    );
  }
}

class PulsingLogo extends StatefulWidget {
  final Gradient gradient;
  const PulsingLogo({super.key, required this.gradient});
  @override
  State<PulsingLogo> createState() => _PulsingLogoState();
}

class _PulsingLogoState extends State<PulsingLogo> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(alignment: Alignment.center, children: [
        _buildRipple(0.0),
        _buildRipple(0.2),
        _buildRipple(0.4),
        GradientText('H', gradient: widget.gradient, style: const TextStyle(fontSize: 72, fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildRipple(double delay) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.2, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Interval(delay, delay + 0.6, curve: Curves.easeInOut))),
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Interval(delay, delay + 0.6, curve: Curves.easeInOut))),
        child: Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.5), width: 2))),
      ),
    );
  }
}

class DotPulseLoader extends StatefulWidget {
  const DotPulseLoader({super.key});
  @override
  State<DotPulseLoader> createState() => _DotPulseLoaderState();
}

class _DotPulseLoaderState extends State<DotPulseLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _buildDot(0.0),
      const SizedBox(width: 15),
      _buildDot(0.25),
      const SizedBox(width: 15),
      _buildDot(0.5),
    ]);
  }

  Widget _buildDot(double delay) {
    return ScaleTransition(
      scale: TweenSequence([
        TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.5), weight: 30),
        TweenSequenceItem(tween: Tween<double>(begin: 1.5, end: 1.0), weight: 30),
        TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 40),
      ]).animate(CurvedAnimation(parent: _controller, curve: Interval(delay, (delay + 0.6).clamp(0.0, 1.0)))),
      child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFFC107), shape: BoxShape.circle)),
    );
  }
}