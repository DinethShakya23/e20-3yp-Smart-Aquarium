import 'package:flutter/material.dart';
import '../Widgets/searchfield.dart';
import '../Widgets/searchbutton.dart';
import '../Widgets/notificationbutton.dart';
import '../Widgets/popupmenu.dart';
import '../Widgets/notificationitem.dart';
import '../Widgets/dashboardrow.dart';
import 'schedulefeed.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
          NotificationButton(_showNotifications),
          PopupMenu(context),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
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

  _filterItems(String query) {
    setState(() {
      _filteredItems = _allItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  _toggleSearch() {
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
            DashboardRow(
                Icons.thermostat,
                "Temperature",
                Colors.redAccent,
                Schedulefeed(),
                Icons.opacity,
                "Turbidity",
                Colors.orangeAccent,
                Schedulefeed()),
            DashboardRow(Icons.science, "pH", Colors.pink, Schedulefeed(),
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
            DashboardRow(
                Icons.notifications,
                "Notifications",
                Colors.green,
                Schedulefeed(),
                Icons.account_circle,
                "Profile",
                Colors.purple,
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
