import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Widgets/searchfield.dart';
import '../Widgets/searchbutton.dart';
import '../Widgets/notificationbutton.dart';
import '../Widgets/popupmenu.dart';
import '../Widgets/notificationitem.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class Schedulefeed extends StatefulWidget {
  const Schedulefeed({super.key});

  @override
  State<Schedulefeed> createState() => _ScheduleFeedState();
}

class _ScheduleFeedState extends State<Schedulefeed> {
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

  int _selectedHour = 12;
  int _selectedMinute = 0;
  int _selectedQuantity = 1;

  String? _scheduledTime;
  String? _scheduledQuantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.home,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: _isSearching
            ? SearchField(_searchController, _filterItems)
            : const Text(
                "Schedule Feed",
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
        child: Column(
          children: [
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

            // Time Selection
            const Text(
              "Select Feeding Time",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    child: CupertinoPicker(
                      backgroundColor: Colors.transparent,
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedHour = index + 1;
                        });
                      },
                      children: List.generate(
                        12,
                        (index) => Center(
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Text(":",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 80,
                    child: CupertinoPicker(
                      backgroundColor: Colors.transparent,
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMinute = index * 5;
                        });
                      },
                      children: List.generate(
                        12,
                        (index) => Center(
                          child: Text(
                            "${index * 5}".padLeft(2, '0'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quantity Selection
            const Text(
              "Select Feed Quantity",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: CupertinoPicker(
                backgroundColor: Colors.transparent,
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedQuantity = (index + 1) * 5;
                  });
                },
                children: List.generate(
                  10,
                  (index) => Center(
                    child: Text(
                      "${(index + 1) * 5} g",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: _setSchedule,

              child: const Text(
                "Set Schedule",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // Display Scheduled Time & Quantity
            if (_scheduledTime != null && _scheduledQuantity != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      "Scheduled Feeding:",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Time: $_scheduledTime hrs",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Quantity: $_scheduledQuantity",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
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

  void _setSchedule() async {
    setState(() {
      _scheduledTime =
      "$_selectedHour:${_selectedMinute.toString().padLeft(2, '0')} ";
      _scheduledQuantity = "$_selectedQuantity g";
    });

    // WebSocket server URI
    final String wsUrl = "ws://13.53.127.196:8081";

    // Prepare the JSON payload
    Map<String, dynamic> data = {
      "time": _scheduledTime,
      "quantity": _selectedQuantity,
    };

    try {
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Send the schedule data as JSON
      channel.sink.add(jsonEncode(data));
      print("✅ Schedule sent successfully via WebSocket");

      // Optionally listen for responses
      channel.stream.listen(
            (message) {
          print("🔄 Server response: $message");
        },
        onError: (error) {
          print("❌ WebSocket error: $error");
        },
        onDone: () {
          print("✅ WebSocket connection closed.");
        },
      );
    } catch (e) {
      print("❌ Error connecting to WebSocket: $e");
    }
  }
}
