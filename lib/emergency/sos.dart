import 'package:flutter/material.dart';

class SosOnboarding extends StatefulWidget {
  const SosOnboarding({super.key});

  @override
  State<SosOnboarding> createState() => _SosOnboardingState();
}

class _SosOnboardingState extends State<SosOnboarding> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: const [
              Center(child: Text("Slide 1", style: TextStyle(fontSize: 24))),
              Center(child: Text("Slide 2", style: TextStyle(fontSize: 24))),
              Center(child: Text("Slide 3", style: TextStyle(fontSize: 24))),
            ],
          ),
          // Dots Indicator
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: _currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
          // Skip button
          if (_currentPage != 2)
            Positioned(
              top: 40,
              right: 20,
              child: TextButton(
                onPressed: () {
                  // Jump to last slide
                  _controller.jumpToPage(2);
                },
                child: const Text("Skip"),
              ),
            ),
          // Next / Get Started button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage == 2) {
                    // Navigate to your SOS setup page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SosSetupPage(),
                      ),
                    );
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                child: Text(_currentPage == 2 ? "Get Started" : "Next"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy SOS setup page
class SosSetupPage extends StatelessWidget {
  const SosSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("SOS Setup Page")),
    );
  }
}