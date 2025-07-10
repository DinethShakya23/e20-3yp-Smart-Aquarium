import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
// import 'dart:async';
// import 'dart:math';

import '../Widgets/searchfield.dart';
import '../Widgets/searchbutton.dart';
import '../Widgets/notificationbutton.dart';
// import '../Widgets/popupmenu.dart';
import '../Widgets/notificationitem.dart';
import '../widgets/PHChart.dart';

class PHLevel extends StatefulWidget {
  final double pH;
  const PHLevel({super.key, required this.pH});

  @override
  State<PHLevel> createState() => _PHLevelState();
}

class _PHLevelState extends State<PHLevel> {
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
  // double pHLevel = 7.0; // Initial dummy value
  // late Timer _timer;

  // @override
  // void initState() {
  //   super.initState();
  //   _simulatePHUpdates();
  // }

  // @override
  // void dispose() {
  //   _timer.cancel();
  //   super.dispose();
  // }

  // void _simulatePHUpdates() {
  //   _timer = Timer.periodic(Duration(seconds: 3), (timer) {
  //     setState(() {
  //       pHLevel = Random().nextDouble() * 14; // Random pH between 0 and 14
  //     });
  //   });
  // }

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
        title:
            _isSearching
                ? SearchField(_searchController, _filterItems)
                : const Text(
                  "pH Level",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        backgroundColor: Colors.blueGrey.shade900,
        elevation: 4.0,
        shadowColor: Colors.blueGrey.shade500,
        actions: [
          SearchButton(_isSearching, _toggleSearch),
          NotificationButton(_showNotifications),
          // PopupMenu(userEmail: widget.userEmail),
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

  Widget _buildDefaultView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ REMOVED: The ClipRRect widget for the logo and its spacing.
            const SizedBox(height: 20),
            const Text(
              "Current pH Level",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // ✅ MODIFIED: Gauge size reduced to 45% of screen width.
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.45,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 5,
                    maximum: 9,
                    ranges: <GaugeRange>[
                      GaugeRange(
                        startValue: 5,
                        endValue: 6.5,
                        color: Colors.red,
                      ),
                      GaugeRange(
                        startValue: 6.5,
                        endValue: 7.5,
                        color: Colors.green,
                      ),
                      GaugeRange(
                        startValue: 7.5,
                        endValue: 9,
                        color: Colors.orange,
                      ),
                    ],
                    pointers: <GaugePointer>[NeedlePointer(value: widget.pH)],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          widget.pH.toStringAsFixed(
                            1,
                          ), // Removed "pH" to avoid clutter
                          style: const TextStyle(
                            fontSize:
                                22, // Slightly larger for better visibility
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

            // ✅ REMOVED: Redundant text widget for pH level.
            const SizedBox(height: 30),
            const Text(
              "pH History",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // ✅ CORRECTED: Using a refactored, embeddable chart widget.
            SizedBox(width: double.infinity, height: 500, child: PHChartPage()),
          ],
        ),
      ),
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
