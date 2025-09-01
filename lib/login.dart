import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // flutter pub add google_fonts
import 'package:firebase_auth/firebase_auth.dart';
import  'package:safe_app/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              child: DecoratedBox(
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
            ),
            SizedBox(height: 70),
            // Username input
            SizedBox(
              width: 370,
              child: TextField(
                controller: _usernameController,
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
                controller: _passwordController,
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
            // Login button
            ElevatedButton(
              onPressed: () {
                String email = _usernameController.text.trim();
                String password = _passwordController.text.trim();

                // Firebase login
                _auth
                    .signInWithEmailAndPassword(
                  email: email,
                  password: password,
                )
                    .then((UserCredential userCredential) {
                  // Login successful → navigate to HomeScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  HomeScreen(),
                    ),
                  );
                }).catchError((error) {
                  // Login failed → show error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Login failed: ${error.toString()}")),
                  );
                });
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
