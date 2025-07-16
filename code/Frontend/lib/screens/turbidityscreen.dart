import 'dart:convert'; // ✅ NEW: For handling JSON data
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // ✅ NEW: For WebSocket connection

import '../Widgets/searchfield.dart';
import '../Widgets/searchbutton.dart';
import '../Widgets/notificationbutton.dart';
import '../Widgets/notificationitem.dart';
import '../Widgets/TurbidityChart.dart';

class Turbidity extends StatefulWidget {
  final double turbidity;

  const Turbidity({super.key, required this.turbidity});

  @override
  State<Turbidity> createState() => _TurbidityState();
}

class _TurbidityState extends State<Turbidity> {
  // ✅ NEW: WebSocket and state variables for real-time data
  late WebSocketChannel _channel;
  late double _currentTurbidity;

  // Existing state variables
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _allItems = [
    "Fish Feeding",
    "Water Change",
    "Filter Cleaning",
    "pH Check",
    "Temperature Monitoring",
  ];
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    // ✅ NEW: Initialize with the passed value and connect to WebSocket
    _currentTurbidity = widget.turbidity; // Start with the initial value
    _connectToWebSocket(); // Connect for live updates
  }

  // ✅ NEW: Method to connect and listen to the WebSocket
  void _connectToWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://18.140.68.45:8081'), // Your WebSocket server URL
    );

    _channel.stream.listen(
      (message) {
        if (!mounted) return; // Ensure widget is still active

        try {
          final data = jsonDecode(message);
          if (data['type'] == 'sensor' && data['data'] is Map) {
            final sensorData = data['data'];
            if (sensorData['turbidity'] != null &&
                sensorData['turbidity'] is num) {
              final newTurbidity = (sensorData['turbidity'] as num).toDouble();
              // Update state only with valid data (not -1)
              if (newTurbidity != -1) {
                setState(() {
                  _currentTurbidity = newTurbidity;
                });
              }
            }
          }
        } catch (e) {
          debugPrint('TurbidityScreen: Error parsing WebSocket data: $e');
        }
      },
      onError: (error) {
        debugPrint('TurbidityScreen: WebSocket Error: $error');
      },
      onDone: () {
        debugPrint('TurbidityScreen: WebSocket connection closed.');
      },
    );
  }

  @override
  void dispose() {
    // ✅ NEW: Important! Close the WebSocket connection.
    _channel.sink.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // Using a back arrow is more intuitive for returning
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:
            _isSearching
                ? SearchField(_searchController, _filterItems)
                : const Text(
                  "Turbidity",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        backgroundColor: Colors.blueGrey.shade900,
        actions: [
          SearchButton(_isSearching, _toggleSearch),
          NotificationButton(_showNotifications),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0468BF), Color(0xFFA1D6F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isSearching ? _buildSearchResults() : _buildDefaultView(),
      ),
    );
  }

  Widget _buildDefaultView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Current Turbidity Level",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.45,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 100,
                    ranges: <GaugeRange>[
                      GaugeRange(
                        startValue: 0,
                        endValue: 30,
                        color: Colors.green,
                      ),
                      GaugeRange(
                        startValue: 30,
                        endValue: 70,
                        color: Colors.orange,
                      ),
                      GaugeRange(
                        startValue: 70,
                        endValue: 100,
                        color: Colors.red,
                      ),
                    ],
                    pointers: <GaugePointer>[
                      // ✅ MODIFIED: Use the real-time state variable
                      NeedlePointer(value: _currentTurbidity),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          // ✅ MODIFIED: Display the real-time state variable
                          "${_currentTurbidity.toStringAsFixed(1)} NTU",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.5,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Turbidity History",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 500,
              child: TurbidityChartPage(),
            ),
          ],
        ),
      ),
    );
  }

  // No changes are needed for the methods below
  void _filterItems(String query) {
    setState(() {
      _filteredItems =
          _allItems
              .where((item) => item.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredItems.clear();
      }
    });
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            _filteredItems[index],
            style: const TextStyle(color: Colors.white),
          ),
          leading: const Icon(Icons.search, color: Colors.white),
          onTap: () {},
        );
      },
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.grey[900],
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.white54),
              NotificationItem(
                Icons.warning,
                "High Temperature",
                "Temperature reached 30°C",
                "2 min ago",
              ),
              NotificationItem(
                Icons.opacity,
                "Turbidity Alert",
                "Water quality has changed",
                "5 min ago",
              ),
              NotificationItem(
                Icons.analytics,
                "Analytics Updated",
                "New data available",
                "10 min ago",
              ),
              NotificationItem(
                Icons.fastfood,
                "Feeding Schedule Updated",
                "New schedule available",
                "2 min ago",
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
