import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_app/grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Disaster Management',
          style: GoogleFonts.aBeeZee(fontSize: 33),
        ),
        backgroundColor: const Color.fromARGB(255, 68, 69, 85),
        foregroundColor: const Color.fromARGB(255, 216, 210, 210),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // Welcome Text
            Center(
              child: Text(
                'Welcome, Nilesh 👍',
                style: GoogleFonts.aBeeZee(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 17, 16, 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // First Grid (Big buttons)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: GridView.count(
                childAspectRatio: 4.1,
                crossAxisCount: 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 25,
                children: const [
                  GridItem(
                    icon: Icons.emergency,
                    text: 'SOS',
                    color: Color.fromARGB(255, 204, 74, 74),
                  ),
                  GridItem(
                    icon: Icons.local_police,
                    text: 'Police',
                    color: Color.fromARGB(255, 42, 52, 138),
                  ),
                  GridItem(
                    icon: Icons.local_fire_department,
                    text: 'Firefighter',
                    color: Color.fromARGB(255, 228, 151, 88),
                  ),
                  GridItem(
                    icon: Icons.local_hospital,
                    text: 'Ambulance',
                    color: Color.fromARGB(255, 6, 134, 91),
                  ),
                ],
              ),
            ),

            const SizedBox(height:30 ),

            // Quick Access Label (aligned with same padding)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Quick Access',
                style: GoogleFonts.aBeeZee(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Second Grid (Small buttons)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  GridItem2(
                      iconcolor: Colors.red,
                      text: 'Disaster Alerts',
                      color: Colors.white,
                      icon: Icons.alarm),
                  GridItem2(
                      iconcolor: Color.fromARGB(255, 77, 85, 199),
                      text: 'Safe zones',
                      color: Colors.white,
                      icon: Icons.map),
                  GridItem2(
                      iconcolor: Color.fromARGB(255, 1, 221, 100),
                      text: 'Guide / First Aid',
                      color: Colors.white,
                      icon: Icons.book),
                ],
              ),
            ),
            
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map'
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile'
            ),
        ],
        ),
    );
  }
}
