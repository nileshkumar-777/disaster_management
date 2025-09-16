import 'dart:ui';
import 'dart:math'; // <--- FIX 1: IMPORT THE MATH LIBRARY
import 'package:flutter/material.dart';

// (The rest of the Data Models and Disaster Data remains the same)
class DisasterInfo {
  final String theme;
  final String title;
  final String subtitle;
  final String footerTitle;
  final String footerSubtitle;
  final List<InstructionSection> sections;
  final Color bgColor;
  final Color textColor;
  final Color navActiveBgColor;
  final Color navActiveTextColor;
  final Color iconBgColor;

  DisasterInfo({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.footerTitle,
    required this.footerSubtitle,
    required this.sections,
    required this.bgColor,
    required this.textColor,
    required this.navActiveBgColor,
    required this.navActiveTextColor,
    required this.iconBgColor,
  });
}

class InstructionSection {
  final String title;
  final List<Instruction> instructions;

  InstructionSection({required this.title, required this.instructions});
}

class Instruction {
  final IconData icon;
  final String text;

  Instruction({required this.icon, required this.text});
}

final Map<String, DisasterInfo> disasterData = {
  'earthquake': DisasterInfo(
    theme: 'earthquake',
    title: 'Earthquake Safety Guide',
    subtitle: 'Essential steps to stay safe during a seismic event.',
    footerTitle: 'After the Shaking Stops',
    footerSubtitle: 'Check for injuries and damage. Be prepared for aftershocks.',
    bgColor: const Color(0xFF655A53),
    textColor: Colors.white,
    navActiveBgColor: const Color(0xFFF7C59F),
    navActiveTextColor: const Color(0xFF4C3F38),
    iconBgColor: Colors.black.withOpacity(0.2),
    sections: [
      InstructionSection(title: 'Immediate Actions', instructions: [
        Instruction(icon: Icons.table_restaurant, text: 'Drop, Cover, and Hold On under a sturdy table or desk.'),
        Instruction(icon: Icons.door_sliding, text: 'Avoid doorways; they do not protect you from falling objects.'),
        Instruction(icon: Icons.apartment, text: 'If indoors, stay inside. If outdoors, find an open area.'),
        Instruction(icon: Icons.power_off, text: 'Be cautious of aftershocks and check for gas leaks.'),
      ]),
    ],
  ),
  'flood': DisasterInfo(
    theme: 'flood',
    title: 'Flood Safety Guide',
    subtitle: 'Essential steps to stay safe.',
    footerTitle: 'After the Flood',
    footerSubtitle: 'Wait for official clearance before re-entering flooded areas.',
    bgColor: const Color(0xFF88C0D0),
    textColor: const Color(0xFF2E3440),
    navActiveBgColor: const Color(0xFF3B4252),
    navActiveTextColor: Colors.white,
    iconBgColor: Colors.white.withOpacity(0.5),
    sections: [
      InstructionSection(title: 'How to Prepare', instructions: [
        Instruction(icon: Icons.map, text: 'Know your flood risk and local elevation.'),
        Instruction(icon: Icons.business_center, text: 'Prepare an emergency kit with essentials.'),
        Instruction(icon: Icons.group, text: 'Create a family evacuation plan.'),
      ]),
      InstructionSection(title: 'How to React', instructions: [
        Instruction(icon: Icons.terrain, text: 'Move to higher ground immediately.'),
        Instruction(icon: Icons.directions_walk, text: 'Do not walk or drive through floodwaters.'),
        Instruction(icon: Icons.electrical_services, text: 'Turn off utilities if instructed to do so.'),
        Instruction(icon: Icons.phone_in_talk, text: 'Stay informed through official alerts.'),
      ]),
    ],
  ),
  'wildfire': DisasterInfo(
    theme: 'wildfire',
    title: 'Forest Fire Safety',
    subtitle: 'Key steps for wildfire preparedness and response.',
    footerTitle: 'When It\'s Over',
    footerSubtitle: 'Wait for official clearance before returning home.',
    bgColor: const Color(0xFFBF616A),
    textColor: Colors.white,
    navActiveBgColor: const Color(0xFFECEFF4),
    navActiveTextColor: const Color(0xFFBF616A),
    iconBgColor: Colors.black.withOpacity(0.2),
    sections: [
      InstructionSection(title: 'Preparedness & Reaction', instructions: [
        Instruction(icon: Icons.home, text: 'Clear flammable materials from around your home.'),
        Instruction(icon: Icons.campaign, text: 'Stay informed and follow official evacuation orders.'),
        Instruction(icon: Icons.air, text: 'Use an air purifier to protect your lungs from smoke.'),
        Instruction(icon: Icons.medical_services, text: 'Have an emergency supply kit ready to go.'),
      ]),
    ],
  ),
  'tsunami': DisasterInfo(
    theme: 'tsunami',
    title: 'Tsunami Safety',
    subtitle: 'Know the signs. Protect yourself and your family.',
    footerTitle: 'After a Tsunami',
    footerSubtitle: 'Wait for official "all clear" before returning to coastal areas.',
    bgColor: const Color(0xFF1A535C),
    textColor: Colors.white,
    navActiveBgColor: const Color(0xFFADE8F4),
    navActiveTextColor: const Color(0xFF1A535C),
    iconBgColor: Colors.black.withOpacity(0.25),
    sections: [
      InstructionSection(title: 'Preparedness & Reaction', instructions: [
        Instruction(icon: Icons.vibration, text: 'If you feel an earthquake, drop, cover, then hold on. When shaking stops, move to high ground.'),
        Instruction(icon: Icons.directions_run, text: 'Evacuate immediately. Do not wait for official warnings.'),
        Instruction(icon: Icons.waves, text: 'Stay away from the coast. A tsunami is a series of waves that may last for hours.'),
        Instruction(icon: Icons.radio, text: 'Listen to emergency information and alerts.'),
      ]),
    ],
  ),
  'tornado': DisasterInfo(
    theme: 'tornado',
    title: 'Tornado Safety',
    subtitle: 'Know the signs. Protect yourself and your family.',
    footerTitle: 'After a Tornado',
    footerSubtitle: 'Stay clear of downed power lines and damaged areas.',
    bgColor: const Color(0xFF4C566A),
    textColor: Colors.white,
    navActiveBgColor: const Color(0xFFD8DEE9),
    navActiveTextColor: const Color(0xFF4C566A),
    iconBgColor: Colors.black.withOpacity(0.2),
    sections: [
      InstructionSection(title: 'Preparedness & Reaction', instructions: [
        Instruction(icon: Icons.radio, text: 'Stay informed. Monitor weather radio, TV, or online sources for tornado watches and warnings.'),
        Instruction(icon: Icons.house_siding, text: 'Go to a safe shelter immediately, such as a basement, storm cellar, or an interior room on the lowest floor.'),
        Instruction(icon: Icons.shield, text: 'Protect your head and neck with your arms. Get under a sturdy piece of furniture if possible.'),
        Instruction(icon: Icons.car_crash, text: 'Avoid windows, doors, and outside walls. Do not stay in a mobile home or vehicle.'),
      ]),
    ],
  ),
};

// ... (The DisasterPrepScreen, DisasterPage, NavBar, and other widgets remain the same)
class DisasterPrepScreen extends StatefulWidget {
  const DisasterPrepScreen({super.key});

  @override
  State<DisasterPrepScreen> createState() => _DisasterPrepScreenState();
}

class _DisasterPrepScreenState extends State<DisasterPrepScreen> {
  String _currentDisasterKey = 'earthquake';

  void _setDisaster(String key) {
    setState(() {
      _currentDisasterKey = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    final disaster = disasterData[_currentDisasterKey]!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: DisasterPage(
        key: ValueKey<String>(_currentDisasterKey),
        disaster: disaster,
        currentDisasterKey: _currentDisasterKey,
        setDisaster: _setDisaster,
      ),
    );
  }
}

class DisasterPage extends StatelessWidget {
  final DisasterInfo disaster;
  final String currentDisasterKey;
  final Function(String) setDisaster;

  const DisasterPage({
    super.key,
    required this.disaster,
    required this.currentDisasterKey,
    required this.setDisaster,
  });

  Widget _buildBackground(String theme) {
    switch (theme) {
      case 'earthquake':
        return const EarthquakeBackground();
      case 'flood':
        return const FloodBackground();
      case 'wildfire':
        return const WildfireBackground();
      case 'tsunami':
        return const TsunamiBackground();
      case 'tornado':
        return const TornadoBackground();
      default:
        return Container(color: disaster.bgColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: disaster.bgColor,
        child: Stack(
          children: [
            _buildBackground(disaster.theme),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    DisasterNavBar(
                      disaster: disaster,
                      currentDisasterKey: currentDisasterKey,
                      setDisaster: setDisaster,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                disaster.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: disaster.textColor,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                disaster.subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: disaster.textColor.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 32),
                              InstructionSectionsList(disaster: disaster),
                              const SizedBox(height: 32),
                              Text(
                                disaster.footerTitle,
                                style: TextStyle(
                                  color: disaster.textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                disaster.footerSubtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: disaster.textColor.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
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

class DisasterNavBar extends StatelessWidget {
  final DisasterInfo disaster;
  final String currentDisasterKey;
  final Function(String) setDisaster;

  const DisasterNavBar({
    super.key,
    required this.disaster,
    required this.currentDisasterKey,
    required this.setDisaster,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: disasterData.entries.map((entry) {
              final key = entry.key;
              final name = '${key[0].toUpperCase()}${key.substring(1)}';
              final isActive = currentDisasterKey == key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setDisaster(key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? disaster.navActiveBgColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? disaster.navActiveTextColor : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class InstructionSectionsList extends StatelessWidget {
  final DisasterInfo disaster;
  const InstructionSectionsList({super.key, required this.disaster});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: disaster.sections.map((section) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
              child: Text(
                section.title,
                style: TextStyle(
                  color: disaster.textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...section.instructions.map((inst) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: disaster.iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(inst.icon, color: disaster.textColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          inst.text,
                          style: TextStyle(
                            color: disaster.textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24), // Space between sections
          ],
        );
      }).toList(),
    );
  }
}

class BackgroundWidgets extends StatelessWidget {
  const BackgroundWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
Widget _buildFloatingIcon(IconData icon, Color color, {double? top, double? bottom, double? left, double? right, double angle = 0, double size = 120, double opacity = 1.0}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: angle * (pi / 180),
        child: Icon(icon, size: size, color: color.withOpacity(opacity)),
      ),
    );
}

class EarthquakeBackground extends StatelessWidget {
  const EarthquakeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(painter: GridPainter(), child: Container()),
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.0), Colors.transparent]))),
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.0), Colors.transparent], stops: const [0.0, 0.5]))),
        _buildFloatingIcon(Icons.apartment, Colors.white, opacity: 0.12, size: 160, top: 40, left: -60, angle: 10),
        _buildFloatingIcon(Icons.home, Colors.white, opacity: 0.15, size: 120, top: MediaQuery.of(context).size.height * 0.3, right: -40, angle: -5),
        _buildFloatingIcon(Icons.architecture, Colors.white, opacity: 0.1, size: 140, bottom: 80, left: 30, angle: 20),
      ],
    );
  }
}

class FloodBackground extends StatelessWidget {
  const FloodBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: FloodWavePainter(
            waveColor: Colors.white.withOpacity(0.12),
            numberOfWaves: 3,
            amplitude: 0.05,
            frequency: 2.0,
          ),
          child: Container(),
        ),
        _buildFloatingIcon(Icons.water_drop, Colors.white, opacity: 0.1, size: 180, top: -50, right: -70, angle: -15),
        _buildFloatingIcon(Icons.waves, Colors.white, opacity: 0.08, size: 150, bottom: 100, left: -50, angle: 20),
        _buildFloatingIcon(Icons.flood, Colors.white, opacity: 0.06, size: 120, top: MediaQuery.of(context).size.height * 0.4, left: -20, angle: -30),
      ],
    );
  }
}

class FloodWavePainter extends CustomPainter {
  final Color waveColor;
  final int numberOfWaves;
  final double amplitude;
  final double frequency;

  FloodWavePainter({
    required this.waveColor,
    this.numberOfWaves = 3,
    this.amplitude = 0.05,
    this.frequency = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0; i < numberOfWaves; i++) {
      final startY = size.height * (0.8 - i * 0.2);
      path.moveTo(0, startY);

      for (double x = 0; x <= size.width; x++) {
        // --- FIX 2: CORRECTLY CALL sin() ---
        final y = startY + (size.height * amplitude * 0.5 * (i + 1)) *
            sin(x / size.width * frequency * 2 * pi); // Use 'pi' constant from dart:math
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class WildfireBackground extends StatelessWidget {
  const WildfireBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
        _buildFloatingIcon(Icons.local_fire_department, Colors.black, opacity: 0.1, size: 200, top: 100, right: -50, angle: -20),
        _buildFloatingIcon(Icons.fireplace, Colors.black, opacity: 0.08, size: 150, bottom: 50, left: -40, angle: 15),
    ]);
  }
}

class TsunamiBackground extends StatelessWidget {
  const TsunamiBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
        _buildFloatingIcon(Icons.waves, Colors.black, opacity: 0.05, size: 250, top: 80, left: -60, angle: 10),
        _buildFloatingIcon(Icons.pool, Colors.black, opacity: 0.05, size: 180, bottom: 60, right: -40, angle: -15),
    ]);
  }
}

class TornadoBackground extends StatelessWidget {
  const TornadoBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
        _buildFloatingIcon(Icons.sync, Colors.black, opacity: 0.08, size: 220, top: 120, right: -50, angle: 0),
        _buildFloatingIcon(Icons.shield, Colors.black, opacity: 0.06, size: 180, bottom: 80, left: -40, angle: 10),
    ]);
  }
}


class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}