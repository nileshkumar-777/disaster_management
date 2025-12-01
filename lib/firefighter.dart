import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:collection/collection.dart';
import 'dart:math';

// -----------------------------------------------------------------------------
// PART 1: Data Model (Fire Department Network Graph)
// -----------------------------------------------------------------------------

// Renamed class to FireNode
class FireNode {
  final String id;
  final String name;
  final LatLng location;
  final String hotline; // Emergency contact hotline
  FireNode(this.id, this.name, this.location, this.hotline);
}

class Edge {
  final String destinationId;
  final double weight;
  const Edge(this.destinationId, this.weight);
}

String _generateRandomHotline() {
  final Random random = Random();
  String phone = '811-';
  for (int i = 0; i < 4; i++) {
    phone += random.nextInt(10).toString();
  }
  return phone;
}

// Global data map: allFireStations
final Map<String, FireNode> allFireStations = {
  'HQ': FireNode(
    'HQ',
    'Main Firehouse / Command',
    LatLng(40.7128, -74.0060),
    '911-0000',
  ),
  'FS1': FireNode(
    'FS1',
    'Fire Station 1 (SW)',
    LatLng(40.7350, -74.0150),
    _generateRandomHotline(),
  ),
  'FS2': FireNode(
    'FS2',
    'Fire Station 2 (Mid)',
    LatLng(40.7550, -73.9950),
    _generateRandomHotline(),
  ),
  'E3': FireNode(
    'E3',
    'Emergency Zone 3 (NE)',
    LatLng(40.7750, -73.9500),
    _generateRandomHotline(),
  ),
  'RS4': FireNode(
    'RS4',
    'Rescue Station 4',
    LatLng(40.7600, -73.9700),
    _generateRandomHotline(),
  ),
  'E5': FireNode(
    'E5',
    'Emergency Zone 5',
    LatLng(40.7400, -73.9600),
    _generateRandomHotline(),
  ),
  'FS6': FireNode(
    'FS6',
    'Fire Station 6 (SE)',
    LatLng(40.7200, -73.9350),
    _generateRandomHotline(),
  ),
  'AC7': FireNode(
    'AC7',
    'Training Academy',
    LatLng(40.7900, -73.9750),
    _generateRandomHotline(),
  ),
};

final Map<String, List<Edge>> adjacencyList = {
  'HQ': [const Edge('FS1', 10), const Edge('FS2', 15), const Edge('E5', 12)],
  'FS1': [const Edge('HQ', 10), const Edge('FS2', 8)],
  'FS2': [const Edge('HQ', 15), const Edge('FS1', 8), const Edge('RS4', 12)],
  'E3': [const Edge('RS4', 7), const Edge('AC7', 10)],
  'RS4': [const Edge('FS2', 12), const Edge('E3', 7), const Edge('E5', 15)],
  'E5': [const Edge('HQ', 12), const Edge('RS4', 15), const Edge('FS6', 10)],
  'FS6': [const Edge('E5', 10)],
  'AC7': [const Edge('E3', 10)],
};

// -----------------------------------------------------------------------------
// PART 2: Dijkstra's Algorithm (References Corrected)
// -----------------------------------------------------------------------------

class PathResult {
  final List<LatLng> path;
  final double distance;
  const PathResult(this.path, this.distance);
}

PathResult findShortestPath(String startId, String endId) {
  // ✅ FIX: Using allFireStations
  if (!allFireStations.containsKey(startId) ||
      !allFireStations.containsKey(endId)) {
    return const PathResult([], 0.0);
  }

  final Map<String, double> distances = {};
  final Map<String, String?> predecessors = {};
  // ✅ FIX: Using allFireStations
  for (var id in allFireStations.keys) {
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
    // ✅ FIX: Using allFireStations
    path.add(allFireStations[current]!.location);
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
// PART 3: Flutter Widget (Firefighter Themed)
// -----------------------------------------------------------------------------

class FireRouteOptimizerWidget extends StatefulWidget {
  const FireRouteOptimizerWidget({super.key});

  @override
  State<FireRouteOptimizerWidget> createState() =>
      _FireRouteOptimizerWidgetState();
}

class _FireRouteOptimizerWidgetState extends State<FireRouteOptimizerWidget> {
  final String _startStationId = 'HQ';
  String? _endStationId;
  PathResult _pathResult = const PathResult([], 0.0);
  int? _selectedUnitId;
  String? _selectedHotline;

  final Random _random = Random();
  final Color _fireRed = Colors.red.shade900;
  final Color _safetyYellow = Colors.amber.shade600;

  @override
  void initState() {
    super.initState();
    _endStationId = 'FS1';
    _calculatePath();
    _updateNodeDetails();
  }

  void _updateNodeDetails() {
    if (_endStationId != null) {
      // ✅ FIX: Using allFireStations
      final node = allFireStations[_endStationId!];
      setState(() {
        _selectedUnitId = 100 + _random.nextInt(400);
        _selectedHotline = node!.hotline;
      });
    }
  }

  void _onNodeTap(String nodeId) {
    if (nodeId != _startStationId) {
      setState(() {
        _endStationId = nodeId;
        _calculatePath();
        _updateNodeDetails();
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
      appBar: AppBar(
        title: const Text('Fire Dispatch Route Optimizer'),
        backgroundColor: _fireRed,
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
                userAgentPackageName: 'com.fire.dispatch_route',
              ),

              // 1. Draw all Edges (Potential Routes)
              PolylineLayer(
                polylines: adjacencyList.entries.expand((entry) {
                  // ✅ FIX: Using allFireStations
                  final start = allFireStations[entry.key]!.location;
                  return entry.value.map((edge) {
                    // ✅ FIX: Using allFireStations
                    final end = allFireStations[edge.destinationId]!.location;
                    return Polyline(
                      points: [start, end],
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 3.0,
                    );
                  });
                }).toList(),
              ),

              // 2. Draw the Shortest Response Path
              if (_pathResult.path.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _pathResult.path,
                      color: _fireRed,
                      strokeWidth: 6.0,
                      isDotted: true,
                    ),
                  ],
                ),

              // 3. Draw all Fire Node Markers
              MarkerLayer(
                // ✅ FIX: Using allFireStations
                markers: allFireStations.entries.map((entry) {
                  final isStart = entry.key == _startStationId;
                  final isEnd = entry.key == _endStationId;

                  final markerIcon = isStart
                      ? Icons.fire_truck
                      : Icons.local_fire_department;
                  final markerColor = isStart ? _safetyYellow : _fireRed;

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
                              color: isStart
                                  ? Colors.red.shade900
                                  : markerColor,
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

          // Custom Top Overlay for Path Length
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
                    color: _fireRed,
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
                        'Estimated Response Time',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatTime(_pathResult.distance),
                        style: TextStyle(
                          color: _safetyYellow,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Fire Station/Zone Details Overlay (Top Right)
          if (_endStationId != null && _selectedUnitId != null)
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
                      border: Border.all(color: _fireRed, width: 2),
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
                          'Emergency Zone:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          // ✅ FIX: Using allFireStations
                          allFireStations[_endStationId!]!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _fireRed,
                            fontSize: 18,
                          ),
                        ),
                        const Divider(),
                        Text(
                          'Responding Unit ID:',
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
                            color: _fireRed,
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _fireRed,
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
                    'Fire Dispatch Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _fireRed,
                    ),
                  ),
                  Text('Start at Main Firehouse 🚒 (Yellow marker).'),
                  Text(
                    'Tap any Station/Zone 🚨 to find the shortest route and view emergency details.',
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
