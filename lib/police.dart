import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:collection/collection.dart';
import 'dart:math';

// -----------------------------------------------------------------------------
// PART 1: Data Model (No changes needed here)
// -----------------------------------------------------------------------------

class PoliceStationNode {
  final String id;
  final String name;
  final LatLng location;
  final String phone;
  PoliceStationNode(this.id, this.name, this.location, this.phone);
}

class Edge {
  final String destinationId;
  final double weight;
  const Edge(this.destinationId, this.weight);
}

String _generateRandomPhone() {
  final Random random = Random();
  String phone = '555-';
  for (int i = 0; i < 4; i++) {
    phone += random.nextInt(10).toString();
  }
  return phone;
}

final Map<String, PoliceStationNode> allPoliceStations = {
  'HQ': PoliceStationNode(
    'HQ',
    'Home Base / Dispatch',
    LatLng(40.7128, -74.0060),
    '555-0000',
  ),
  'P1': PoliceStationNode(
    'P1',
    'Precinct 1 (SW)',
    LatLng(40.7350, -74.0150),
    _generateRandomPhone(),
  ),
  'P2': PoliceStationNode(
    'P2',
    'Precinct 2 (Mid)',
    LatLng(40.7550, -73.9950),
    _generateRandomPhone(),
  ),
  'P3': PoliceStationNode(
    'P3',
    'Precinct 3 (NE)',
    LatLng(40.7750, -73.9500),
    _generateRandomPhone(),
  ),
  'S4': PoliceStationNode(
    'S4',
    'Sub-Station 4',
    LatLng(40.7600, -73.9700),
    _generateRandomPhone(),
  ),
  'F5': PoliceStationNode(
    'F5',
    'Field Office 5',
    LatLng(40.7400, -73.9600),
    _generateRandomPhone(),
  ),
  'P6': PoliceStationNode(
    'P6',
    'Precinct 6 (SE)',
    LatLng(40.7200, -73.9350),
    _generateRandomPhone(),
  ),
  'T7': PoliceStationNode(
    'T7',
    'Training Academy',
    LatLng(40.7900, -73.9750),
    _generateRandomPhone(),
  ),
};

final Map<String, List<Edge>> adjacencyList = {
  'HQ': [const Edge('P1', 10), const Edge('P2', 15), const Edge('F5', 12)],
  'P1': [const Edge('HQ', 10), const Edge('P2', 8)],
  'P2': [const Edge('HQ', 15), const Edge('P1', 8), const Edge('S4', 12)],
  'P3': [const Edge('S4', 7), const Edge('T7', 10)],
  'S4': [const Edge('P2', 12), const Edge('P3', 7), const Edge('F5', 15)],
  'F5': [const Edge('HQ', 12), const Edge('S4', 15), const Edge('P6', 10)],
  'P6': [const Edge('F5', 10)],
  'T7': [const Edge('P3', 10)],
};

// -----------------------------------------------------------------------------
// PART 2: Dijkstra's Algorithm (No changes needed here)
// -----------------------------------------------------------------------------

class PathResult {
  final List<LatLng> path;
  final double distance;
  const PathResult(this.path, this.distance);
}

PathResult findShortestPath(String startId, String endId) {
  if (!allPoliceStations.containsKey(startId) ||
      !allPoliceStations.containsKey(endId)) {
    return const PathResult([], 0.0);
  }

  final Map<String, double> distances = {};
  final Map<String, String?> predecessors = {};
  for (var id in allPoliceStations.keys) {
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
    path.add(allPoliceStations[current]!.location);
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
// PART 3: Flutter Widget (Repositioning Fix)
// -----------------------------------------------------------------------------

class PoliceRouteOptimizerWidget extends StatefulWidget {
  const PoliceRouteOptimizerWidget({super.key});

  @override
  State<PoliceRouteOptimizerWidget> createState() =>
      _PoliceRouteOptimizerWidgetState();
}

class _PoliceRouteOptimizerWidgetState
    extends State<PoliceRouteOptimizerWidget> {
  final String _startStationId = 'HQ';
  String? _endStationId;
  PathResult _pathResult = const PathResult([], 0.0);
  int? _selectedStationRandomId;
  String? _selectedStationPhone;

  final Random _random = Random();
  final Color _policeBlue = Colors.blue.shade800;
  final Color _homeColor = Colors.green.shade600;

  @override
  void initState() {
    super.initState();
    _endStationId = 'P1';
    _calculatePath();
    _updateStationDetails();
  }

  void _updateStationDetails() {
    if (_endStationId != null) {
      final station = allPoliceStations[_endStationId!];
      setState(() {
        _selectedStationRandomId = 100 + _random.nextInt(900);
        _selectedStationPhone = station!.phone;
      });
    }
  }

  void _onStationTap(String stationId) {
    if (stationId != _startStationId) {
      setState(() {
        _endStationId = stationId;
        _calculatePath();
        _updateStationDetails();
      });
    }
  }

  void _calculatePath() {
    if (_endStationId != null) {
      _pathResult = findShortestPath(_startStationId, _endStationId!);
    } else {
      _pathResult = const PathResult([], 0.0);
    }
  }

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
                userAgentPackageName: 'com.police.route_optimizer',
              ),

              PolylineLayer(
                polylines: adjacencyList.entries.expand((entry) {
                  final start = allPoliceStations[entry.key]!.location;
                  return entry.value.map((edge) {
                    final end = allPoliceStations[edge.destinationId]!.location;
                    return Polyline(
                      points: [start, end],
                      color: Colors.blueGrey.withOpacity(0.3),
                      strokeWidth: 3.0,
                    );
                  });
                }).toList(),
              ),

              if (_pathResult.path.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _pathResult.path,
                      color: _policeBlue,
                      strokeWidth: 6.0,
                      isDotted: false,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: allPoliceStations.entries.map((entry) {
                  final isStart = entry.key == _startStationId;
                  final isEnd = entry.key == _endStationId;

                  final markerIcon = isStart ? Icons.home : Icons.local_police;
                  final markerColor = isStart
                      ? _homeColor
                      : Colors.blue.shade600;

                  return Marker(
                    width: 60.0,
                    height: 60.0,
                    point: entry.value.location,

                    child: GestureDetector(
                      onTap: () => _onStationTap(entry.key),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isStart ? _homeColor : markerColor,
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

          // Custom Top Overlay for Path Length (Top Center)
          if (_endStationId != null)
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
                    color: _policeBlue,
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
                        'Estimated Dispatch Time',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatTime(_pathResult.distance),
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

          // 🚨 FIX HERE: Police Station ID and Phone Overlay (Top Right)
          if (_endStationId != null && _selectedStationRandomId != null)
            Align(
              alignment: Alignment.topRight, // Aligned to top right
              child: SizedBox(
                width: 250, // Constraint maximum width
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 100.0,
                    right: 16.0,
                  ), // Pushed down from AppBar
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _policeBlue, width: 2),
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
                          'Station Name:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          allPoliceStations[_endStationId!]!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _policeBlue,
                            fontSize: 18,
                          ),
                        ),
                        const Divider(),
                        Text(
                          'Station ID / Extension:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '#${_selectedStationRandomId}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _policeBlue,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Phone No:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _selectedStationPhone!,
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
                    'Dispatch Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _policeBlue,
                    ),
                  ),
                  Text('Start at Home Base 🏠 (Green marker).'),
                  Text(
                    'Tap any Police Station 🛡️ to find the shortest route and view station details.',
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
