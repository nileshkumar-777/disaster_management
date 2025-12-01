import 'package:flutter/material.dart';
import 'dart:async';

class SOSButton extends StatefulWidget {
  const SOSButton({super.key});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  static const double _buttonSize = 200.0;
  static const Color _redColor = Color(0xFFE53935);
  static const Duration _requiredHoldDuration = Duration(seconds: 3);

  // Animation controller is now used only for pulsing feedback during hold
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  bool _isHolding = false;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    // Animation controller setup is the same, but it will NOT auto-repeat
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 3.0, end: 12.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  // --- Press and Hold Logic ---

  void _onPressStart(LongPressStartDetails details) {
    _holdTimer?.cancel();

    setState(() {
      _isHolding = true;
    });

    // ⭐️ PERFORMANCE FIX ⭐️: Start the animation and let it pulse only while holding
    _animationController.repeat(reverse: true);

    // Start the timer for activation
    _holdTimer = Timer(_requiredHoldDuration, () {
      if (_isHolding) {
        _onHoldComplete();
      }
    });
  }

  void _onGestureEnd() {
    if (!mounted || !_isHolding) return;

    _holdTimer?.cancel();

    // ⭐️ PERFORMANCE FIX ⭐️: Stop the pulsing immediately
    _animationController.stop();

    // Reset holding state and animation to the minimum value smoothly
    _animationController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
    );

    setState(() {
      _isHolding = false;
    });
  }

  void _onHoldComplete() {
    if (!mounted || !_isHolding) return;

    // Final reset state and run action
    setState(() {
      _isHolding = false;
    });

    _holdTimer?.cancel();
    _animationController.stop();
    _animationController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
    ); // Smoothly fade out glow

    // 💡 SOS ACTIVATION ACTION 💡
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS ACTIVATED! Sending emergency message...'),
      ),
    );
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    // ⭐️ PERFORMANCE OPTIMIZATION ⭐️: Use the AnimatedBuilder only for the shadow effect
    return GestureDetector(
      onLongPressStart: _onPressStart,
      onLongPressUp: _onGestureEnd,
      onLongPressCancel: _onGestureEnd,
      behavior: HitTestBehavior.opaque,

      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(209, 61, 5, 5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use an AnimatedBuilder ONLY around the Container that uses the animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  // Only use the animation value when the button is held down
                  final double glowValue = _isHolding
                      ? _glowAnimation.value.clamp(1.0, 15.0)
                      : 0.0; // Set to 0 when not holding

                  // Use a fixed, subtle glow when not holding for visual presence
                  final double baseGlow = 4.0;

                  final double finalBlur =
                      (_isHolding ? glowValue * 2 : baseGlow).clamp(1.0, 50.0);
                  final double finalSpread =
                      (_isHolding ? glowValue * 0.5 : baseGlow * 0.5).clamp(
                        0.5,
                        10.0,
                      );

                  return Container(
                    width: _buttonSize,
                    height: _buttonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _redColor,
                      boxShadow: [
                        BoxShadow(
                          color: _redColor.withOpacity(_isHolding ? 1.0 : 0.8),
                          blurRadius: finalBlur,
                          spreadRadius: finalSpread,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: const Center(
                  child: ExcludeSemantics(
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              const ExcludeSemantics(
                child: Text(
                  'Press and hold to activate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
