import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient header
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4238F7),
                    Color(0xFF5E7BF8),
                    Color(0xFFD6E6FA),
                    Color(0xFFFFFFFF),
                  ],
                  stops: [0.0, 0.2, 0.73, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/logo.png",
                        height: 90,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'SafeZone',
                        style: GoogleFonts.montserrat(fontSize: 33),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Stay alert, stay alive',
                    style: GoogleFonts.sahitya(fontSize: 40),
                  ),
                ],
              ),
            ),
            SizedBox(height: 70),
            // Username input
            SizedBox(
              width: 370,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'User Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 60),
            // Password input
            SizedBox(
              width: 370,
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 80),
            // Login button (does nothing)
            ElevatedButton(
              onPressed: () {
                // Empty for now
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(370, 50),
                backgroundColor: const Color.fromARGB(255, 59, 59, 59),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Log in',
                style: GoogleFonts.sahitya(fontSize: 26),
              ),
            ),
            SizedBox(height: 0),
            // Bottom gradient container
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4238F7),
                    Color(0xFF5E7BF8),
                    Color(0xFFD6E6FA),
                    Color(0xFFFFFFFF),
                  ],
                  stops: [0.0, 0.2, 0.73, 1.0],
                  end: Alignment.topCenter,
                  begin: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}