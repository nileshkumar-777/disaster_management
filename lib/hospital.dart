import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:collection/collection.dart'; // For PriorityQueue
import 'dart:math'; // For random number generation

// -----------------------------------------------------------------------------
// PART 1: Data Model (Hospital Network Graph)
// -----------------------------------------------------------------------------

// Defines a medical facility/zone node
class MedicalNode {
  final String id;
  final String name;
  final LatLng location;
  final String emergencyHotline; // Emergency contact hotline
  MedicalNode(this.id, this.name, this.location, this.emergencyHotline);
}

// Defines a route (edge) - Weights are travel time in minutes
class Edge {
  final String destinationId;
  final double weight; // The travel time/cost in minutes
  const Edge(this.destinationId, this.weight);
}

// Function to generate a random simulated emergency hotline number
String _generateRandomHotline() {
  final Random random = Random();
  String phone = '911-';
  for (int i = 0; i < 4; i++) {
    phone += random.nextInt(10).toString();
  }
  return phone;
}

// Global data map: allMedicalNodes
final Map<String, MedicalNode> allMedicalNodes = {
  'AMB': MedicalNode(
    'AMB',
    'Ambulance Dispatch Base',
    LatLng(40.7128, -74.0060),
    '911-0000',
  ),
  'H1': MedicalNode(
    'H1',
    'City General Hospital',
    LatLng(40.7350, -74.0150),
    _generateRandomHotline(),
  ),
  'C2': MedicalNode(
    'C2',
    'Urgent Care Clinic',
    LatLng(40.7550, -73.9950),
    _generateRandomHotline(),
  ),
  'H3': MedicalNode(
    'H3',
    'St. Jude Trauma Center',
    LatLng(40.7750, -73.9500),
    _generateRandomHotline(),
  ),
  'E4': MedicalNode(
    'E4',
    'E-Response Zone 4',
    LatLng(40.7600, -73.9700),
    _generateRandomHotline(),
  ),
  'F5': MedicalNode(
    'F5',
    'Field Triage Point',
    LatLng(40.7400, -73.9600),
    _generateRandomHotline(),
  ),
  'C6': MedicalNode(
    'C6',
    'Westside Clinic',
    LatLng(40.7200, -73.9350),
    _generateRandomHotline(),
  ),
  'H7': MedicalNode(
    'H7',
    'Childrens Hospital',
    LatLng(40.7900, -73.9750),
    _generateRandomHotline(),
  ),
};

// Adjacency List (Ambulance Routes)
final Map<String, List<Edge>> adjacencyList = {
  'AMB': [const Edge('H1', 10), const Edge('C2', 15), const Edge('F5', 12)],
  'H1': [const Edge('AMB', 10), const Edge('C2', 8)],
  'C2': [const Edge('AMB', 15), const Edge('H1', 8), const Edge('E4', 12)],
  'H3': [const Edge('E4', 7), const Edge('H7', 10)],
  'E4': [const Edge('C2', 12), const Edge('H3', 7), const Edge('F5', 15)],
  'F5': [const Edge('AMB', 12), const Edge('E4', 15), const Edge('C6', 10)],
  'C6': [const Edge('F5', 10)],
  'H7': [const Edge('H3', 10)],
};

// -----------------------------------------------------------------------------
// PART 2: Dijkstra's Algorithm
// -----------------------------------------------------------------------------

class PathResult {
  final List<LatLng> path;
  final double distance; // NOTE: This is the shortest TIME in minutes
  const PathResult(this.path, this.distance);
}

PathResult findShortestPath(String startId, String endId) {
  if (!allMedicalNodes.containsKey(startId) ||
      !allMedicalNodes.containsKey(endId)) {
    return const PathResult([], 0.0);
  }

  final Map<String, double> distances = {};
  final Map<String, String?> predecessors = {};
  for (var id in allMedicalNodes.keys) {
    distances[id] = double.infinity;
    predecessors[id] = null;
  }
  distances[startId] = 0.0;

  final PriorityQueue<(double, String)> priorityQueue = PriorityQueue(
    ((a, b) => a.$1.compareTo(b.$1)),
  );
  priorityQueue.add((0.0, startId));

  while (priorityQueue.isNotEmpty) {
    final (currentDistance, currentId) = priorityQueue.removeFirst();

    if (currentDistance > distances[currentId]!) {
      continue;
    }

    if (currentId == endId) {
      break;
    }

    for (var edge in adjacencyList[currentId] ?? []) {
      final neighborId = edge.destinationId;
      final newDistance = currentDistance + edge.weight;

      if (newDistance < distances[neighborId]!) {
        distances[neighborId] = newDistance;
        predecessors[neighborId] = currentId;
        priorityQueue.add((newDistance, neighborId));
      }
    }
  }

  final List<LatLng> path = [];
  String? current = endId;
  while (current != null) {
    path.add(allMedicalNodes[current]!.location);
    if (current == startId) break;
    current = predecessors[current];
  }

  final shortestPath = path.reversed.toList();
  final shortestDistance = distances[endId] == double.infinity
      ? 0.0
      : distances[endId]!;

  return PathResult(shortestPath, shortestDistance);
}

// -----------------------------------------------------------------------------
// PART 3: Flutter Widget (Time Output Restored)
// -----------------------------------------------------------------------------

class AmbulanceRouteOptimizerWidget extends StatefulWidget {
  const AmbulanceRouteOptimizerWidget({super.key});

  @override
  State<AmbulanceRouteOptimizerWidget> createState() =>
      _AmbulanceRouteOptimizerWidgetState();
}

class _AmbulanceRouteOptimizerWidgetState
    extends State<AmbulanceRouteOptimizerWidget> {
  final String _startNodeId = 'AMB'; // Fixed start point: Ambulance Base
  String? _endNodeId;
  PathResult _pathResult = const PathResult([], 0.0);
  int? _selectedUnitId;
  String? _selectedHotline;

  final Random _random = Random();
  final Color _emergencyRed = Colors.red.shade700;
  final Color _dispatchGreen = Colors.green.shade600;

  @override
  void initState() {
    super.initState();
    _endNodeId = 'H1';
    _calculatePath();
    _updateNodeDetails();
  }

  void _updateNodeDetails() {
    if (_endNodeId != null) {
      final node = allMedicalNodes[_endNodeId!];
      setState(() {
        _selectedUnitId = 500 + _random.nextInt(500);
        _selectedHotline = node!.emergencyHotline;
      });
    }
  }

  void _onNodeTap(String nodeId) {
    if (nodeId != _startNodeId) {
      setState(() {
        _endNodeId = nodeId;
        _calculatePath();
        _updateNodeDetails();
      });
    }
  }

  void _calculatePath() {
    if (_endNodeId != null) {
      _pathResult = findShortestPath(_startNodeId, _endNodeId!);
    } else {
      _pathResult = const PathResult([], 0.0);
    }
  }

  // Restored function to display time in Hours and Minutes
  String _formatTime(double minutes) {
    if (minutes == 0) return '0m';
    final hours = (minutes / 60).floor();
    final remainingMinutes = (minutes % 60).round();

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    }
    return '${remainingMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulance Dispatch Optimizer'),
        backgroundColor: _emergencyRed,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(40.75, -73.97),
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.emergency.ambulance_dispatch',
              ),

              // 1. Draw all Edges (Potential Routes)
              PolylineLayer(
                polylines: adjacencyList.entries.expand((entry) {
                  final start = allMedicalNodes[entry.key]!.location;
                  return entry.value.map((edge) {
                    final end = allMedicalNodes[edge.destinationId]!.location;
                    return Polyline(
                      points: [start, end],
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 3.0,
                    );
                  });
                }).toList(),
              ),

              // 2. Draw the Shortest Ambulance Route
              if (_pathResult.path.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _pathResult.path,
                      color: _emergencyRed,
                      strokeWidth: 6.0,
                      isDotted: false,
                    ),
                  ],
                ),

              // 3. Draw all Medical Node Markers
              MarkerLayer(
                markers: allMedicalNodes.entries.map((entry) {
                  final isStart = entry.key == _startNodeId;
                  final isEnd = entry.key == _endNodeId;

                  // Marker Icon Logic: Ambulance for Start, Hospital/Cross for others
                  final markerIcon = isStart
                      ? Icons.local_shipping
                      : Icons.local_hospital;
                  final markerColor = isStart
                      ? _dispatchGreen
                      : Colors.red.shade700;

                  return Marker(
                    width: 60.0,
                    height: 60.0,
                    point: entry.value.location,

                    child: GestureDetector(
                      onTap: () => _onNodeTap(entry.key),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isStart ? _dispatchGreen : markerColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isEnd
                                    ? Colors.yellowAccent
                                    : Colors.white,
                                width: isEnd ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              markerIcon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Text(
                            entry.value.name.split(' ').first,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              backgroundColor: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Custom Top Overlay for Path Length (TIME)
          if (_endNodeId != null)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 25,
                  ),
                  decoration: BoxDecoration(
                    color: _emergencyRed,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Estimated Dispatch Time', // Changed back from Distance
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatTime(_pathResult.distance), // Displaying Time
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Medical Node ID and Emergency Line Overlay (Top Right)
          if (_endNodeId != null && _selectedUnitId != null)
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 250,
                child: Padding(
                  padding: const EdgeInsets.only(top: 100.0, right: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _emergencyRed, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Facility Name:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          allMedicalNodes[_endNodeId!]!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _emergencyRed,
                            fontSize: 18,
                          ),
                        ),
                        const Divider(),
                        Text(
                          'Ambulance Unit ID:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '#${_selectedUnitId}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _emergencyRed,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Emergency Hotline:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _selectedHotline!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Instructions/Info Overlay at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              color: Colors.white.withOpacity(0.95),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Dispatch:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _emergencyRed,
                    ),
                  ),
                  Text('Start at Ambulance Base 🚑 (Green marker).'),
                  Text(
                    'Tap any Medical Facility 🏥 to find the shortest route and view details.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
