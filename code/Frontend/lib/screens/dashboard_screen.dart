import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Widgets/dashboardrow.dart';
import '../Widgets/notificationbutton.dart';
import '../Widgets/notificationitem.dart';
import '../widgets/popupmenu.dart';
import '../Widgets/searchbutton.dart';
import '../Widgets/searchfield.dart';
import 'phscreen.dart';
import 'schedulefeed.dart';
import 'temperaturescreen.dart';
import 'turbidityscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashBoard extends StatefulWidget {
  final String userEmail;

  const DashBoard({super.key, required this.userEmail});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://0.0.0.0:8081'),
  );

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _allItems = [
    "Temperature",
    "Turbidity",
    "pH",
    "Schedule Feed",
    "Analytics",
    "Settings",
    "Messages",
    "Profile"
  ];
  List<String> _filteredItems = [];

  double TemperatureLevel = 30.0;
  double pHLevel = 7.0;
  double turbidityLevel = 50.0;
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _saveUserEmail(widget.userEmail);
    _listenToWebSocket();
  }

  // Save userEmail to SharedPreferences for persistence
  Future<void> _saveUserEmail(String email) async {
    if (email.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', email);
    }
  }

  void _listenToWebSocket() {
    debugPrint("🔌 Connecting to WebSocket...");

    channel.stream.listen(
      (message) {
        debugPrint("📩 Received Raw WebSocket Message: $message");

        try {
          Map<String, dynamic> jsonData = jsonDecode(message);

          if (jsonData['type'] == 'sensor' &&
              jsonData['data'] is Map<String, dynamic>) {
            Map<String, dynamic> data = jsonData['data'];

            setState(() {
              TemperatureLevel =
                  (data['temperature'] as num?)?.toDouble() ?? TemperatureLevel;
              pHLevel = (data['pH'] as num?)?.toDouble() ?? pHLevel;
              turbidityLevel =
                  (data['turbidity'] as num?)?.toDouble() ?? turbidityLevel;
            });

            debugPrint(
                "✅ Updated Values - 🌡 Temp: $TemperatureLevel°C, pH: $pHLevel, 💧 Turbidity: $turbidityLevel NTU");
          } else {
            debugPrint("⚠️ Unexpected WebSocket message format: $jsonData");
          }
        } catch (e) {
          debugPrint("❌ Error parsing WebSocket data: $e");
        }
      },
      onError: (error) => debugPrint("❌ WebSocket Error: $error"),
      onDone: () => debugPrint("🔌 WebSocket connection closed."),
      cancelOnError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: _isSearching
            ? SearchField(_searchController, _filterItems)
            : const Text("Dashboard",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey.shade900,
        elevation: 4.0,
        shadowColor: Colors.blueGrey.shade500,
        actions: [
          SearchButton(_isSearching, _toggleSearch),
          NotificationButton(_showNotifications), // ✅ Corrected
          DashboardPopupMenu(userEmail: widget.userEmail),
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
        child: _isSearching ? _buildSearchResults() : _buildDashboard(),
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

  Widget _buildInfoCard(IconData icon, String value, Color color) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_filteredItems[index],
              style: const TextStyle(color: Colors.white)),
          leading: const Icon(Icons.search, color: Colors.white),
          onTap: () {},
        );
      },
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Image.asset("assert/images/Logo00.jpg",
                  height: 86, width: 86, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: _buildInfoCard(Icons.thermostat,
                        "$TemperatureLevel°C", Colors.redAccent)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildInfoCard(Icons.opacity, "$turbidityLevel NTU",
                        Colors.orangeAccent)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildInfoCard(
                        Icons.science, "$pHLevel", Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 20),
            DashboardRow(
                Icons.thermostat,
                "Temperature",
                Colors.redAccent,
                Temperature(),
                Icons.opacity,
                "Turbidity",
                Colors.orangeAccent,
                Turbidity()),
            DashboardRow(Icons.science, "pH", Colors.pink, PHLevel(),
                Icons.timer, "Schedule Feed", Colors.redAccent, Schedulefeed()),
            DashboardRow(
                Icons.analytics,
                "Analytics",
                Colors.indigo,
                Schedulefeed(),
                Icons.settings,
                "Settings",
                Colors.amber,
                Schedulefeed()),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("Notifications",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              Divider(color: Colors.white54),
              NotificationItem(Icons.warning, "High Temperature",
                  "Temperature reached 30°C", "2 min ago"),
              NotificationItem(Icons.opacity, "Turbidity Alert",
                  "Water quality has changed", "5 min ago"),
              NotificationItem(Icons.analytics, "Analytics Updated",
                  "New data available", "10 min ago"),
              NotificationItem(Icons.fastfood, "Feeding Schedule Updated",
                  "New schedule available", "2 min ago"),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    debugPrint("🛑 WebSocket Closed.");
    super.dispose();
  }
}
