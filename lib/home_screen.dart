import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_app/guide.dart'; // Ensure this file contains DisasterPrepScreen
import 'package:safe_app/profile.dart'; // Ensure this file contains ProfileScreenWidget
import 'package:safe_app/home screen/sos.dart';
import 'package:safe_app/home screen/resources.dart';
import 'package:safe_app/home screen/alert.dart';
import "package:safe_app/safeplace.dart";
import 'package:safe_app/firefighter.dart';
import 'package:safe_app/hospital.dart';
import 'package:safe_app/police.dart';

class DisasterManagementApp extends StatelessWidget {
  const DisasterManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Management',
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      home: const DisasterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DisasterScreen extends StatefulWidget {
  const DisasterScreen({super.key});

  @override
  State<DisasterScreen> createState() => _DisasterScreenState();
}

class _DisasterScreenState extends State<DisasterScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const _HomeScreenContent(),
    const KnapsackApp(),
    const AlertScreen(),
    const ProfileScreenWidget(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank_rounded),
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

//--- Home Screen Content ---//
class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            WelcomeHeader(),
            SizedBox(height: 24.0),
            _DisasterAlertCard(),
            SizedBox(height: 24.0),
            EmergencyServices(), // ✅ fixed name
            SizedBox(height: 24.0),
            QuickAccess(),
          ],
        ),
      ),
    );
  }
}

//--- Dynamic Welcome Header Widget ---//
class WelcomeHeader extends StatefulWidget {
  const WelcomeHeader({super.key});

  @override
  State<WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<WelcomeHeader> {
  late Future<String?> _userNameFuture;

  @override
  void initState() {
    super.initState();
    _userNameFuture = _fetchUserName();
  }

  Future<String?> _fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          return userDoc.get('name');
        }
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _userNameFuture,
      builder: (context, snapshot) {
        String displayName = '...';
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError || !snapshot.hasData) {
            displayName = 'User';
          } else {
            displayName = snapshot.data!;
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFE5E7EB),
              child: Icon(Icons.person, size: 30, color: Color(0xFF9CA3AF)),
            ),
          ],
        );
      },
    );
  }
}

//--- Disaster Alert Card ---//
class _DisasterAlertCard extends StatelessWidget {
  const _DisasterAlertCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disaster Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'High-intensity earthquake expected',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(Icons.warning_rounded, color: Colors.white, size: 36),
        ],
      ),
    );
  }
}

//--- Emergency Services Section ---//
class EmergencyServices extends StatelessWidget {
  const EmergencyServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16.0),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.5,
          children: [
            _EmergencyServiceButton(
              icon: Icons.sos,
              label: 'SOS',
              color: const Color(0xFFEF4444),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        Scaffold(body: const Center(child: QuickSetupScreen())),
                  ),
                );
              },
            ),
            _EmergencyServiceButton(
              icon: Icons.local_police,
              label: 'Police',
              color: const Color(0xFF3B82F6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      body: const Center(child: PoliceRouteOptimizerWidget()),
                    ),
                  ),
                );
              },
            ),
            _EmergencyServiceButton(
              icon: Icons.local_fire_department,
              label: 'Firefighter',
              color: const Color(0xFFF97316),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      body: const Center(child: FireRouteOptimizerWidget()),
                    ),
                  ),
                );
              },
            ),
            _EmergencyServiceButton(
              icon: Icons.medical_services_rounded,
              label: 'Ambulance',
              color: const Color(0xFF22C55E),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      body: const Center(
                        child: AmbulanceRouteOptimizerWidget(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _EmergencyServiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyServiceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String title;

  const DetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          "Welcome to $title service",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

//--- Quick Access Section ---//
class QuickAccess extends StatelessWidget {
  const QuickAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16.0),
        _QuickAccessItem(
          icon: Icons.pin_drop,
          title: 'Safe Zones',
          subtitle: 'Find the nearest safe locations',
          backgroundColor: const Color(0xFFDCFCE7),
          iconColor: const Color(0xFF166534),
          titleColor: const Color(0xFF14532D),
          subtitleColor: const Color(0xFF15803D),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ShortestPathFinderWidget(),
              ),
            );
          },
        ),
        const SizedBox(height: 16.0),
        _QuickAccessItem(
          icon: Icons.book_outlined,
          title: 'Guide / First Aid',
          subtitle: 'Essential survival information',
          backgroundColor: const Color(0xFFDBEAFE),
          iconColor: const Color(0xFF2563EB),
          titleColor: const Color(0xFF1E3A8A),
          subtitleColor: const Color(0xFF1D4ED8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DisasterPrepScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback? onTap;

  const _QuickAccessItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: subtitleColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: iconColor, size: 16),
          ],
        ),
      ),
    );
  }
}

//--- Placeholder Safe Zones Page ---//
class SafeZonesPage extends StatelessWidget {
  const SafeZonesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Zones'),
        backgroundColor: const Color(0xFFDCFCE7),
      ),
      body: const Center(child: Text('This is the Safe Zones Page.')),
    );
  }
}

// class QuickSetupScreen extends StatelessWidget {
//   const QuickSetupScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Quick Setup')),
//       body: const Center(child: Text('Setup your SOS contacts here')),
//     );
//   }
// }
