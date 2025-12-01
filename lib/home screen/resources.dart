import 'package:flutter/material.dart';
import 'dart:math';

// --- 1. Data Model ---

class ResourceItem {
  final int id;
  final String name;
  final int importance; // Value
  final double weight;
  final String icon; // Emoji icon for visual appeal

  ResourceItem({
    required this.id,
    required this.name,
    required this.importance,
    required this.weight,
    required this.icon,
  });
}

// --- 2. Main Application Setup ---

class KnapsackApp extends StatelessWidget {
  const KnapsackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Knapsack Optimizer',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const KnapsackOptimizer(),
    );
  }
}

// --- 3. Knapsack Core Widget ---

class KnapsackOptimizer extends StatefulWidget {
  const KnapsackOptimizer({super.key});

  @override
  State<KnapsackOptimizer> createState() => _KnapsackOptimizerState();
}

class _KnapsackOptimizerState extends State<KnapsackOptimizer> {
  // Initial data matching the previous example
  final List<ResourceItem> items = [
    ResourceItem(
      id: 1,
      name: "Water Bottle",
      importance: 10,
      weight: 1.0,
      icon: '💧',
    ),
    ResourceItem(
      id: 2,
      name: "First Aid Kit",
      importance: 8,
      weight: 2.0,
      icon: '🩹',
    ),
    ResourceItem(
      id: 3,
      name: "Blanket",
      importance: 6,
      weight: 1.5,
      icon: '🛌',
    ),
    ResourceItem(
      id: 4,
      name: "Satellite Phone",
      importance: 15,
      weight: 0.5,
      icon: '📞',
    ),
    ResourceItem(
      id: 5,
      name: "Rations (MRE)",
      importance: 7,
      weight: 2.5,
      icon: '🥫',
    ),
  ];

  double capacity = 3.0; // Default capacity
  List<ResourceItem> selectedItems = [];
  double totalWeight = 0.0;
  int totalImportance = 0;

  final TextEditingController _capacityController = TextEditingController();
  // Using a GlobalKey is standard practice for ScaffoldMessenger
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _capacityController.text = capacity.toString();
    // Calculate initial state immediately on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateOptimalResources();
    });
  }

  @override
  void dispose() {
    _capacityController.dispose();
    super.dispose();
  }

  // --- Knapsack Algorithm (0/1 DP) ---

  void _calculateOptimalResources() {
    // Safety check for input
    final currentCapacity = double.tryParse(_capacityController.text) ?? 0.0;
    if (currentCapacity <= 0) {
      _showSnackbar('Please enter a valid positive capacity.');
      setState(() {
        selectedItems = [];
        totalWeight = 0.0;
        totalImportance = 0;
      });
      return;
    }

    setState(() {
      capacity = currentCapacity;
    });

    const int scale = 10; // Scale factor for handling decimal weights
    final int scaledCapacity = (capacity * scale).floor();

    final List<int> scaledWeights = items
        .map((item) => (item.weight * scale).floor())
        .toList();
    final List<int> values = items.map((item) => item.importance).toList();
    final int n = items.length;

    // Dynamic Programming table K[i][w]
    final List<List<int>> K = List.generate(
      n + 1,
      (_) => List.filled(scaledCapacity + 1, 0),
    );

    // Build K table
    for (int i = 0; i <= n; i++) {
      for (int w = 0; w <= scaledCapacity; w++) {
        if (i == 0 || w == 0) {
          K[i][w] = 0;
        } else if (scaledWeights[i - 1] <= w) {
          // Max of (not including item i) OR (including item i)
          K[i][w] = max(
            K[i - 1][w],
            values[i - 1] + K[i - 1][w - scaledWeights[i - 1]],
          );
        } else {
          // Cannot include item i
          K[i][w] = K[i - 1][w];
        }
      }
    }

    // Traceback to find selected items
    int currentImportance = K[n][scaledCapacity];
    int currentWeightIndex = scaledCapacity;
    List<ResourceItem> tempSelectedItems = [];
    double tempTotalWeight = 0.0;

    for (int i = n; i > 0 && currentImportance > 0; i--) {
      // If the value changed, item 'i-1' was included
      if (currentImportance != K[i - 1][currentWeightIndex]) {
        final selectedItem = items[i - 1];
        tempSelectedItems.add(selectedItem);

        currentImportance -= values[i - 1];
        currentWeightIndex -= scaledWeights[i - 1];
        tempTotalWeight += selectedItem.weight;
      }
    }

    setState(() {
      // items are added in reverse order, so we reverse them back
      selectedItems = tempSelectedItems.reversed.toList();
      totalWeight = tempTotalWeight;
      // Get the final maximum importance from the DP table
      totalImportance = K[n][scaledCapacity];
    });
  }

  void _showSnackbar(String message) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- 4. UI Layout ---

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        backgroundColor: const Color(0xfff7fafc),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Disaster Resource Allocation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          leading: const Icon(
            Icons.handshake_outlined,
            color: Color(0xFF4F46E5),
          ), // Custom Icon
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF9CA3AF)),
              onPressed: () {
                _showSnackbar("Adding custom items is not yet implemented.");
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Capacity Input Section
              const Text(
                'Maximum Capacity (Weight in kg)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _capacityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter capacity in kg',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: Color(0xFF3B82F6),
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: (_) => _calculateOptimalResources(),
              ),
              const SizedBox(height: 24),

              // Item List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ResourceCard(item: item);
                },
              ),
              const SizedBox(height: 32),

              // Calculate Button (Gradient Style)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF34D399),
                      Color(0xFF06B6D4),
                    ], // Tailwind teal/cyan gradient
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _calculateOptimalResources,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .transparent, // Transparent background for gradient
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Calculate Optimal Resources',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Results Section - FIX APPLIED HERE:
              // The conditional check was removed to ensure the output is always shown
              // after the calculation runs, even if no items are selected.
              _buildResultsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Optimal Resource Allocation',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),

          // Selected Items List
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Items:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                if (selectedItems.isEmpty)
                  const Text(
                    'No items selected. Capacity may be too low or zero.',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  ...selectedItems
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '• ${item.name} (${item.weight.toStringAsFixed(1)}kg, Imp: ${item.importance})',
                            style: const TextStyle(color: Color(0xFF4B5563)),
                          ),
                        ),
                      )
                      .toList(),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Total Weight
          _buildResultMetric(
            label: 'Total Weight:',
            value:
                '${totalWeight.toStringAsFixed(1)} kg / ${capacity.toStringAsFixed(1)} kg',
            color: const Color(0xFFD1E7F7), // Blue-50 equivalent background
            valueColor: const Color(0xFF3B82F6), // Blue-600 equivalent text
          ),
          const SizedBox(height: 8),

          // Total Importance
          _buildResultMetric(
            label: 'Total Importance:',
            value: '$totalImportance',
            color: const Color(0xFFD1FAE5), // Green-50 equivalent background
            valueColor: const Color(0xFF059669), // Green-600 equivalent text
            isLarge: true,
          ),
          const SizedBox(height: 16),

          const Center(
            child: Text(
              'Maximized benefit using Knapsack optimization.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultMetric({
    required String label,
    required String value,
    required Color color,
    required Color valueColor,
    bool isLarge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 24 : 18,
              fontWeight: isLarge ? FontWeight.w900 : FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 5. Item Card Widget ---

class ResourceCard extends StatelessWidget {
  final ResourceItem item;

  const ResourceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Placeholder for future item editing functionality
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item.icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Importance: ${item.importance} | Weight: ${item.weight.toStringAsFixed(1)}kg',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Remove Button Placeholder
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: Color(0xFF9CA3AF),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Removing items is not yet implemented."),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
