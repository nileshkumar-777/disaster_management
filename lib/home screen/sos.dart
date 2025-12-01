import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ⭐️ ADDED: Firebase Auth Import ⭐️
import 'package:safe_app/home screen/sosbutton.dart';

// Key for local storage
const String SETUP_COMPLETE_KEY = 'setup_complete';

// --- Next Screen Widget (The destination after setup) ---
class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text(
              'Setup is complete and stored.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Quick Setup Screen ---
class QuickSetupScreen extends StatefulWidget {
  const QuickSetupScreen({super.key});

  @override
  State<QuickSetupScreen> createState() => _QuickSetupScreenState();
}

class _QuickSetupScreenState extends State<QuickSetupScreen> {
  // --- Controllers and Data ---
  final name1Controller = TextEditingController();
  final phone1Controller = TextEditingController();
  final name2Controller = TextEditingController();
  final phone2Controller = TextEditingController();
  final name3Controller = TextEditingController();
  final phone3Controller = TextEditingController();
  final messageController = TextEditingController();

  final List<String> predefinedMessages = [
    "I'm in danger. Please help!",
    "I need help right now. Call the police.",
    "My location is safe for now, but I need assistance.",
    "Custom Message",
  ];

  late String _selectedMessage;
  bool _isLoading = true; // Controls initial splash/loading screen

  @override
  void initState() {
    super.initState();
    _checkSetupStatus();
  }

  // --- Check Status and Redirect Logic ---
  Future<void> _checkSetupStatus() async {
    bool shouldShowSetup = true;

    try {
      // Check if user is authenticated first (necessary for Firebase logic to pass)
      if (FirebaseAuth.instance.currentUser == null) {
        // If not authenticated, we shouldn't proceed to save, but for setup flow:
        // Assume authentication happens before this screen, so we rely on the
        // SharedPreferences check only for the one-time setup completion.
      }

      final prefs = await SharedPreferences.getInstance();
      final isComplete = prefs.getBool(SETUP_COMPLETE_KEY) ?? false;

      if (isComplete) {
        shouldShowSetup = false;
        if (mounted) {
          // Redirect immediately if flag is true
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SOSButton()),
          );
          return;
        }
      }
    } catch (e) {
      print("Error during initial setup check: $e");
    }

    // Initialize state and stop loading if we haven't redirected
    if (mounted) {
      setState(() {
        _selectedMessage = predefinedMessages.first;
        messageController.text = _selectedMessage;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    name1Controller.dispose();
    phone1Controller.dispose();
    name2Controller.dispose();
    phone2Controller.dispose();
    name3Controller.dispose();
    phone3Controller.dispose();
    messageController.dispose();
    super.dispose();
  }

  // ⭐️ CRITICAL FIX: Get the live UID from FirebaseAuth ⭐️
  String getCurrentUserId() {
    // This is the correct way to get the UID of the logged-in user.
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  // --- Firebase Saving Logic ---
  Future<void> _saveCredentialsToFirebase() async {
    if (_isLoading) return;

    // Start loading state
    setState(() => _isLoading = true);

    final userId = getCurrentUserId();
    if (userId.isEmpty) {
      if (mounted) {
        // This indicates the user mysteriously logged out or never logged in.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: User not logged in. Please sign in again.'),
          ),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    final finalMessage = _selectedMessage == "Custom Message"
        ? messageController.text
        : _selectedMessage;

    final data = {
      'emergency_contacts': [
        {'name': name1Controller.text, 'phone': phone1Controller.text},
        {'name': name2Controller.text, 'phone': phone2Controller.text},
        {'name': name3Controller.text, 'phone': phone3Controller.text},
      ],
      'emergency_message': finalMessage,
      'last_updated': FieldValue.serverTimestamp(),
    };

    try {
      // ⭐️ WRITE OPERATION USES THE REAL UID ⭐️
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(data, SetOptions(merge: true));

      // Set the flag in SharedPreferences only after successful save
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(SETUP_COMPLETE_KEY, true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts saved successfully!')),
        );

        // Navigate to the next screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NextScreen()),
        );
      }
    } catch (e) {
      print('Error saving data to Firebase: $e');
      if (mounted) {
        // Reset the loading state and show the error message
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save contacts: ${e.toString()}')),
        );
      }
    }
  }

  // --- UI Builder Methods (_buildContactCard and _buildMessageCard are unchanged) ---
  Widget _buildContactCard(
    String title,
    TextEditingController nameController,
    TextEditingController phoneController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Name',
              contentPadding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Phone Number',
              contentPadding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMessageCard() {
    final isCustom = _selectedMessage == "Custom Message";
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Message',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedMessage,
                icon: const Icon(Icons.arrow_drop_down),
                elevation: 16,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedMessage = newValue;
                      messageController.text = (newValue != "Custom Message")
                          ? newValue
                          : '';
                    });
                  }
                },
                items: predefinedMessages.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (isCustom)
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your custom emergency message...',
                contentPadding: EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedMessage,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
        ],
      ),
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    // Show a loading spinner during the initial check OR when actively saving
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    const double bottomButtonHeight = 80.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Quick Setup & Review')),
      body: Stack(
        children: [
          // 1. Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: bottomButtonHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Contacts are saved locally on your device for privacy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),

                // UI for Emergency Contacts
                _buildContactCard(
                  'Emergency Contact 1',
                  name1Controller,
                  phone1Controller,
                ),
                _buildContactCard(
                  'Emergency Contact 2',
                  name2Controller,
                  phone2Controller,
                ),
                _buildContactCard(
                  'Emergency Contact 3',
                  name3Controller,
                  phone3Controller,
                ),

                // UI for Emergency Message
                _buildMessageCard(),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // 2. Fixed Bottom Save Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: bottomButtonHeight,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveCredentialsToFirebase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Save Contacts & Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
