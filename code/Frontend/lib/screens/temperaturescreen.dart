import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:async';
import 'dart:math'; // Import for random turbidity values

import '../Widgets/searchfield.dart';
import '../Widgets/searchbutton.dart';
import '../Widgets/notificationbutton.dart';
import '../Widgets/popupmenu.dart';
import '../Widgets/notificationitem.dart';

class Temperature extends StatefulWidget {
  const Temperature({super.key});

  @override
  State<Temperature> createState() => _TemperatureState();
}

class _TemperatureState extends State<Temperature> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _allItems = [
    "Fish Feeding",
    "Water Change",
    "Filter Cleaning",
    "pH Check",
    "Temperature Monitoring"
  ];
  List<String> _filteredItems = [];
  double TemperatureLevel = 30.0; // Initial dummy value
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _simulateTurbidityUpdates();
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  void _simulateTurbidityUpdates() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        TemperatureLevel =
            20 + Random().nextDouble() * 80; // Random between 20-100
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: _isSearching
            ? SearchField(_searchController, _filterItems)
            : const Text(
                "Temperature",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
        backgroundColor: Colors.blueGrey.shade900,
        elevation: 4.0,
        shadowColor: Colors.blueGrey.shade500,
        actions: [
          SearchButton(_isSearching, _toggleSearch),
          NotificationButton(_showNotifications),
          PopupMenu(context),
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

  void _filterItems(String query) {
    setState(() {
      _filteredItems = _allItems
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

  Widget _buildDefaultView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: Image.asset(
              "assert/images/Logo00.jpg",
              height: 86,
              width: 86,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image_not_supported,
                size: 86,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Current Temperature",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Corrected Gauge Implementation
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.6,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 10,
                  maximum: 40,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 22,
                      color: Colors.orange,
                    ),
                    GaugeRange(
                      startValue: 22,
                      endValue: 28,
                      color: Colors.green,
                    ),
                    GaugeRange(
                      startValue: 28,
                      endValue: 40,
                      color: Colors.red,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(value: TemperatureLevel),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        "${TemperatureLevel.toStringAsFixed(1)} °C",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      angle: 90,
                      positionFactor: 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text(
            "Temperature: ${TemperatureLevel.toStringAsFixed(1)} °C",
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                ),
                child: const Icon(Icons.arrow_upward),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                ),
                child: const Icon(Icons.arrow_downward),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.grey[900],
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Notifications",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white54),
              NotificationItem(Icons.warning, "High Temperature",
                  "Temperature reached 30°C", "2 min ago"),
              NotificationItem(Icons.opacity, "Turbidity Alert",
                  "Water quality has changed", "5 min ago"),
              NotificationItem(Icons.analytics, "Analytics Updated",
                  "New data available", "10 min ago"),
              NotificationItem(Icons.fastfood, "Feeding Schedule Updated",
                  "New schedule available", "2 min ago"),
              const SizedBox(height: 10),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close",
                      style: TextStyle(color: Colors.blueAccent))),
            ],
          ),
        );
      },
    );
  }
}
