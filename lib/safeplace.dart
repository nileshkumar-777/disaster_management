import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:collection/collection.dart'; // For PriorityQueue

// -----------------------------------------------------------------------------
// PART 1: Data Model (Graph Representation - Based on the Image)
// -----------------------------------------------------------------------------

// Represents a node (point) on our custom map
class Node {
  final String id;
  final LatLng location;
  Node(this.id, this.location);
}

// Represents a connection (edge) between two nodes
class Edge {
  final String destinationId;
  final double weight; // The time/cost in minutes
  const Edge(this.destinationId, this.weight);
}

// Define node locations based loosely on the visual layout in a map context
final Map<String, Node> allNodes = {
  '1': Node('1', LatLng(40.760, -73.960)),
  '2': Node('2', LatLng(40.740, -73.940)),
  '3': Node('3', LatLng(40.780, -73.940)),
  '4': Node('4', LatLng(40.765, -73.900)),
  '5': Node('5', LatLng(40.745, -73.880)),
  '6': Node('6', LatLng(40.775, -73.860)),
  '7': Node('7', LatLng(40.795, -73.880)),
};

// Adjacency List: key is the source node ID, value is a list of edges
final Map<String, List<Edge>> adjacencyList = {
  '1': [const Edge('3', 30), const Edge('2', 30)],
  '2': [const Edge('1', 30), const Edge('4', 20), const Edge('5', 25)],
  '3': [const Edge('1', 30), const Edge('7', 150)],
  '4': [const Edge('2', 20), const Edge('7', 70), const Edge('5', 15)],
  '5': [const Edge('2', 25), const Edge('4', 15), const Edge('6', 30)],
  '6': [const Edge('5', 30), const Edge('7', 45)],
  '7': [const Edge('4', 70), const Edge('6', 45), const Edge('3', 150)],
};

// -----------------------------------------------------------------------------
// PART 2: Dijkstra's Algorithm
// -----------------------------------------------------------------------------

class PathResult {
  final List<LatLng> path;
  final double distance; // Total distance in minutes
  const PathResult(this.path, this.distance);
}

PathResult findShortestPath(String startId, String endId) {
  if (!allNodes.containsKey(startId) || !allNodes.containsKey(endId)) {
    return const PathResult([], 0.0);
  }

  final Map<String, double> distances = {};
  final Map<String, String?> predecessors = {};
  for (var id in allNodes.keys) {
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

  // Path Reconstruction
  final List<LatLng> path = [];
  String? current = endId;
  while (current != null) {
    path.add(allNodes[current]!.location);
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
// PART 3: Flutter Widget
// -----------------------------------------------------------------------------

class ShortestPathFinderWidget extends StatefulWidget {
  const ShortestPathFinderWidget({super.key});

  @override
  State<ShortestPathFinderWidget> createState() =>
      _ShortestPathFinderWidgetState();
}

class _ShortestPathFinderWidgetState extends State<ShortestPathFinderWidget> {
  final String _startNodeId = '1';
  String? _endNodeId;
  PathResult _pathResult = const PathResult([], 0.0);

  @override
  void initState() {
    super.initState();
    _endNodeId = '2';
    _calculatePath();
  }

  void _onNodeTap(String nodeId) {
    if (nodeId != _startNodeId) {
      setState(() {
        _endNodeId = nodeId;
        _calculatePath();
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

  String _formatTime(double minutes) {
    if (minutes == 0) return '0 Mins';
    final hours = (minutes / 60).floor();
    final remainingMinutes = (minutes % 60).round();

    if (hours > 0) {
      return '${hours} Hr ${remainingMinutes} Mins';
    }
    return '${remainingMinutes} Mins';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Route Optimizer'),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(40.76, -73.91),
              initialZoom: 12.0,
              // ✅ FIX 1: Removed the problematic interaction parameters
              // The map will now use default interaction (pan/zoom enabled)
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.delivery.route_optimizer',
              ),

              // 1. Draw all Edges (Potential Routes)
              PolylineLayer(
                polylines: adjacencyList.entries.expand((entry) {
                  final start = allNodes[entry.key]!.location;
                  return entry.value.map((edge) {
                    final end = allNodes[edge.destinationId]!.location;
                    return Polyline(
                      points: [start, end],
                      color: Colors.purple.withOpacity(0.5),
                      strokeWidth: 4.0,
                    );
                  });
                }).toList(),
              ),

              // 2. Draw the Shortest Path Polyline
              if (_pathResult.path.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _pathResult.path,
                      color: const Color(0xFF6A1B9A),
                      strokeWidth: 6.0,
                      isDotted: true,
                    ),
                  ],
                ),

              // 3. Draw all Nodes (the numbered stops)
              MarkerLayer(
                markers: allNodes.entries.map((entry) {
                  final isStart = entry.key == _startNodeId;
                  final isEnd = entry.key == _endNodeId;
                  final color = isStart
                      ? Colors.lightGreen
                      : isEnd
                      ? Colors.red
                      : Colors.white;

                  return Marker(
                    width: 40.0,
                    height: 40.0,
                    point: entry.value.location,

                    // ✅ FIX 2: Removed complex 'anchor' parameter
                    // Marker positioning defaults to center, which is always supported.
                    child: GestureDetector(
                      onTap: () => _onNodeTap(entry.key),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isStart
                              ? Colors.green.shade700
                              : const Color(0xFF6A1B9A),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isEnd ? Colors.red : Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Custom Top Overlay for Path Length (mimicking the image style)
          if (_endNodeId != null)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B9A),
                    borderRadius: BorderRadius.circular(12),
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
                        'Total Path Length (Time)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatTime(_pathResult.distance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '1 → ${_endNodeId}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Instructions/Info Overlay at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              color: Colors.white.withOpacity(0.9),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                  Text('Starting Point is fixed at Node 1 (Green).'),
                  Text(
                    'Tap any other node (2-7) to find the shortest time route.',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Route: 1 → ${_endNodeId ?? 'Select Destination'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _pathResult.distance > 0.0
                          ? Colors.black
                          : Colors.blueGrey,
                    ),
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
