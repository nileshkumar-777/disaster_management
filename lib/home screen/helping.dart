import 'package:flutter/material.dart';
//import 'package:safe_app/home screen/home_screen.dart';



class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(color: Color(0xFF6B7280)), // text-gray-500
            ),
            Text(
              'Nilesh',
              style: TextStyle(
                fontSize: 24, // text-2xl
                fontWeight: FontWeight.bold, // font-bold
                color: Color(0xFF111827), // text-gray-900
              ),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 24, // w-12 h-12 -> 48px diameter
          backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAJMP6swgyU1Dt2MTlyFHDYVXnaDFdA1pCSNNvoxoIQB6yG7ryBqPhg2J-PkJBSz0OvVf1kTRZEirmmFSwcebU0CKnnkzoeK9ZG0twHepOeumqbG4seve7Atjv04ThckJpV8CzicZYSYfTUuxDD2Z0Pg6DX9_I-YN7lBBAKPFvNrDRvRSVkCuEf43uoNCmOCeHiIrb3eb_RFxYDS09KKBJt6xXNOva6KlP7kRZWKU2sO0Ifki4cgMF4pUujRwPl5mjwt5cLwCF_YqM'),
          backgroundColor: Color(0xFFE5E7EB), // bg-gray-200
        ),
      ],
    );
  }
}



class _DisasterAlertCard extends StatelessWidget {
  const _DisasterAlertCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0), // p-4
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444), // bg-red-500
        borderRadius: BorderRadius.circular(16.0), // rounded-2xl
        boxShadow: [ // shadow-lg
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
                    fontSize: 18, // text-lg
                    fontWeight: FontWeight.bold, // font-bold
                  ),
                ),
                Text(
                  'High-intensity earthquake expected',
                  style: TextStyle(color: Colors.white, fontSize: 14), // text-sm
                ),
              ],
            ),
          ),
          Icon(Icons.warning_rounded, color: Colors.white, size: 36), // material-symbols-outlined + text-4xl
        ],
      ),
    );
  }
}

class _EmergencyServices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency Services',
          style: TextStyle(
            fontSize: 18, // text-lg
            fontWeight: FontWeight.w600, // font-semibold
            color: Color(0xFF1F2937), // text-gray-800
          ),
        ),
        const SizedBox(height: 16.0), // mb-4
        GridView.count(
          crossAxisCount: 2, // grid-cols-2
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16.0, // gap-4
          mainAxisSpacing: 16.0,  // gap-4
          childAspectRatio: 1.5,
          children: const [
            _EmergencyServiceButton(icon: Icons.sos, label: 'SOS', color: Color(0xFFEF4444)),
            _EmergencyServiceButton(icon: Icons.local_police, label: 'Police', color: Color(0xFF3B82F6)),
            _EmergencyServiceButton(icon: Icons.local_fire_department, label: 'Firefighter', color: Color(0xFFF97316)),
            _EmergencyServiceButton(icon: Icons.medical_services_rounded, label: 'Ambulance', color: Color(0xFF22C55E)),
          ],
        ),
      ],
    );
  }
}

// Reusable button widget for the Emergency Services grid
class _EmergencyServiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _EmergencyServiceButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1, // shadow-sm
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // rounded-2xl
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30), // text-3xl
            const SizedBox(height: 8.0), // mb-2
            Text(
              label,
              style: const TextStyle(
                fontSize: 16, // text-base
                fontWeight: FontWeight.w500, // font-medium
                color: Color(0xFF374151), // text-gray-700
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Quick Access Section
class _QuickAccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 18, // text-lg
            fontWeight: FontWeight.w600, // font-semibold
            color: Color(0xFF1F2937), // text-gray-800
          ),
        ),
        const SizedBox(height: 16.0), // mb-4
        const _QuickAccessItem(
          icon: Icons.pin_drop,
          title: 'Safe Zones',
          subtitle: 'Find the nearest safe locations',
          backgroundColor: Color(0xFFDCFCE7), // bg-green-100
          iconColor: Color(0xFF166534), // text-green-600
          titleColor: Color(0xFF14532D), // text-green-800
          subtitleColor: Color(0xFF15803D), // text-green-700
        ),
        const SizedBox(height: 16.0), // space-y-4
        const _QuickAccessItem(
          icon: Icons.book_outlined,
          title: 'Guide / First Aid',
          subtitle: 'Essential survival information',
          backgroundColor: Color(0xFFDBEAFE), // bg-blue-100
          iconColor: Color(0xFF2563EB), // text-blue-600
          titleColor: Color(0xFF1E3A8A), // text-blue-800
          subtitleColor: Color(0xFF1D4ED8), // Equivalent text-blue-700
        ),
      ],
    );
  }
}

// Reusable widget for the Quick Access items
class _QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;

  const _QuickAccessItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0), // p-4
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.0), // rounded-2xl
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 30), // text-3xl
            const SizedBox(width: 16.0), // mr-4
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600, // font-semibold
                      color: titleColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14, // text-sm
                      color: subtitleColor,
                    ),
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