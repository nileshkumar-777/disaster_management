import 'package:flutter/material.dart';

// --- 1. Data Model and Priority Enum ---

// Enum for defining the priority level (lower number means higher priority/more severe)
enum AlertPriority {
  severeEmergency(0), // Red
  warning(1), // Orange
  advisory(2), // Yellow
  community(3); // Green

  final int level;
  const AlertPriority(this.level);

  // Helper function to get the correct color based on priority
  Color get color {
    switch (this) {
      case AlertPriority.severeEmergency:
        return const Color(0xFFE53935); // Red
      case AlertPriority.warning:
        return const Color(0xFFFB8C00); // Deep Orange
      case AlertPriority.advisory:
        return const Color(0xFFFDD835); // Yellow
      case AlertPriority.community:
        return const Color(0xFF43A047); // Green
    }
  }
}

class AlertItem {
  final String title;
  final String timeAgo;
  final AlertPriority priority;

  AlertItem({
    required this.title,
    required this.timeAgo,
    required this.priority,
  });
}

// --- 2. Main Alert Screen Widget with Priority Queue Logic ---

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  // Sample Data matching the image, assigned priority levels
  final List<AlertItem> _allAlerts = [
    AlertItem(
      title: "Severe Thunderstorm Warning",
      timeAgo: "5 minutes ago",
      priority: AlertPriority.severeEmergency,
    ),
    AlertItem(
      title: "Flash Flood Watch in your area",
      timeAgo: "15 minutes ago",
      priority: AlertPriority.severeEmergency,
    ),
    AlertItem(
      title: "Road Closure on Main St",
      timeAgo: "10:30 AM",
      priority: AlertPriority.warning,
    ),
    AlertItem(
      title: "Community BBQ this weekend",
      timeAgo: "Yesterday",
      priority: AlertPriority.community,
    ),
    AlertItem(
      title: "Park Cleanup Volunteer Call",
      timeAgo: "2 days ago",
      priority: AlertPriority.community,
    ),
  ];

  late List<AlertItem> _sortedAlerts;

  @override
  void initState() {
    super.initState();
    // Initialize and sort the alerts immediately upon creation
    _sortAlertsByPriority();
  }

  // Priority Queue Logic: Sorts the list based on the AlertPriority level.
  void _sortAlertsByPriority() {
    // Create a mutable copy and sort it
    _sortedAlerts = List.from(_allAlerts);
    _sortedAlerts.sort((a, b) => a.priority.level.compareTo(b.priority.level));
  }

  // Function to handle alert removal and state update
  void _removeAlert(int index) {
    setState(() {
      // 1. Remove the item from the source list to persist the change
      final removedItem = _sortedAlerts.removeAt(index);
      _allAlerts.removeWhere((item) => item.title == removedItem.title);

      // Show confirmation/undo snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${removedItem.title} dismissed.'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the number of active alerts by counting ALL alerts in the display list.
    // This ensures that "5 Active" is shown initially.
    final int activeCount = _sortedAlerts.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Light gray background
      body: SafeArea(
        child: Column(
          children: [
            // --- Custom AppBar/Header ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: Color(0xFF333333),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Emergency Alerts',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935), // Red badge color
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '$activeCount Active',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // --- Sorted Alerts List (The Priority Queue Output) ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _sortedAlerts.length,
                itemBuilder: (context, index) {
                  final item = _sortedAlerts[index];

                  // --- Dismissible Widget for swipe-to-remove ---
                  return Dismissible(
                    key: Key(
                      item.title,
                    ), // Unique key is required for Dismissible
                    direction:
                        DismissDirection.endToStart, // Only swipe right-to-left
                    onDismissed: (direction) {
                      _removeAlert(index);
                    },
                    // Background shown during the swipe action
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: AlertCard(item: item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar is intentionally excluded.
    );
  }
}

// --- Alert Card Widget ---

class AlertCard extends StatelessWidget {
  final AlertItem item;

  const AlertCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: item.priority.color, // Color based on priority
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.timeAgo,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
