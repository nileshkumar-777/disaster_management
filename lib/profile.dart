import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreenWidget extends StatefulWidget {
  const ProfileScreenWidget({super.key});

  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  // State variables
  String? _name;
  String? _bio;
  int? _age;
  String? _imageUrl;
  String? _bloodGroup;
  String? _height;
  String? _weight;

  bool _isLoading = true;
  bool _needsInput = false; // <-- flag for first-time input

  final _formKey = GlobalKey<FormState>();
  final _bloodController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _name = data['name'];
          _bio = data['bio'];
          _age = data['age'];
          _imageUrl = data['profileImageUrl'];
          _bloodGroup = data['bloodGroup'];
          _height = data['height'];
          _weight = data['weight'];
          _isLoading = false;

          // If these fields are missing -> show input form
          if (_bloodGroup == null || _height == null || _weight == null) {
            _needsInput = true;
          }
        });
      } else {
        setState(() => _needsInput = true); // No document yet -> ask input
      }
    } catch (e) {
      print("Error loading profile: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'bloodGroup': _bloodController.text,
      'height': _heightController.text,
      'weight': _weightController.text,
    }, SetOptions(merge: true));

    setState(() {
      _bloodGroup = _bloodController.text;
      _height = _heightController.text;
      _weight = _weightController.text;
      _needsInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // If user needs to input details first time
    if (_needsInput) {
      return Scaffold(
        appBar: AppBar(title: const Text("Complete Your Profile")),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _bloodController,
                  decoration: const InputDecoration(labelText: "Blood Group"),
                  validator: (v) => v!.isEmpty ? "Enter blood group" : null,
                ),
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(labelText: "Height"),
                  validator: (v) => v!.isEmpty ? "Enter height" : null,
                ),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: "Weight"),
                  validator: (v) => v!.isEmpty ? "Enter weight" : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveProfileData();
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Otherwise show profile as before
    return Stack(
      children: [
        Positioned.fill(
          child: _imageUrl != null && _imageUrl!.isNotEmpty
              ? Image.network(_imageUrl!, fit: BoxFit.cover)
              : Image.asset('assets/big1.jpg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.95),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                '${_name ?? 'No Name'}, ${_age ?? ''}',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              _buildSectionCard(
                title: 'ABOUT ME',
                child: Text(
                  _bio ?? 'No Bio available.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFC0C0D4),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard('Blood Group', _bloodGroup ?? '---'),
                  _buildInfoCard('Height', _height ?? '---'),
                  _buildInfoCard('Weight', _weight ?? '---'),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF252125),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE9E6FF),
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6.0),
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xFF252125),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(fontSize: 12, color: Color(0xFFC0C0D4))),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
