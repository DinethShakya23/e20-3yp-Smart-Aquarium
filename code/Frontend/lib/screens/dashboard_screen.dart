import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/profile_screen.dart';
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
import 'seeFish_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'Notification.dart';
import 'change_wifi_screen.dart';

class DashBoard extends StatefulWidget {
  final String userEmail;

  const DashBoard({super.key, required this.userEmail});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final channel = WebSocketChannel.connect(Uri.parse('ws://54.211.9.164:8081'));

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _allItems = [
    "Temperature",
    "Turbidity",
    "pH",
    "Schedule Feed",
    "See Fish Activity",
    "Profile",
    "Change Wi-Fi",
  ];
  List<String> _filteredItems = [];

  double TemperatureLevel = 30.0;
  double pHLevel = 7.0;
  double turbidityLevel = 50.0;
  String userEmail = "";

  String webSocketStatus = "Not connected.";

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
    debugPrint("🔌 Connecting ...");

    setState(() {
      webSocketStatus = "🔌 Connecting ...";
    });

    channel.stream.listen(
      (message) {
        debugPrint("📩 Received Raw WebSocket Message: $message");

        try {
          Map<String, dynamic> jsonData = jsonDecode(message);
          if (jsonData['type'] == 'sensor' &&
              jsonData['data'] is Map<String, dynamic>) {
            Map<String, dynamic> data = jsonData['data'];

            List<String> missingFields = [];
            List<String> invalidFields = [];

            if (!data.containsKey('temperature')) {
              missingFields.add('Temperature');
            } else if (data['temperature'] is num) {
              double temp = data['temperature'].toDouble();
              if (temp < 0 || temp > 50) {
                invalidFields.add('Temperature out of range (-50°C to 150°C)');
              }
            }

            if (!data.containsKey('pH')) {
              missingFields.add('pH');
            } else if (data['pH'] is num) {
              double pH = data['pH'].toDouble();
              if (pH < 0 || pH > 14) {
                invalidFields.add('pH out of range (0 to 14)');
              }
            }

            if (!data.containsKey('turbidity')) {
              missingFields.add('Turbidity');
            } else if (data['turbidity'] is num) {
              double turbidity = data['turbidity'].toDouble();
              if (turbidity < 0 || turbidity > 1000) {
                invalidFields.add('Turbidity out of range (0 to 1000 NTU)');
              }
            }

            if (missingFields.isNotEmpty) {
              debugPrint("⚠️ Missing sensor data: ${missingFields.join(', ')}");

              setState(() {
                webSocketStatus =
                    "⚠️ Device failure: Missing data from ${missingFields.join(', ')} sensor(s).";
              });
            } else if (invalidFields.isNotEmpty) {
              debugPrint("⚠️ Invalid sensor data: ${invalidFields.join(', ')}");

              setState(() {
                webSocketStatus =
                    "⚠️ Device failure: Invalid data - ${invalidFields.join(', ')}.";
              });
            } else {
              setState(() {
                TemperatureLevel =
                    (data['temperature'] as num?)?.toDouble() ??
                    TemperatureLevel;
                pHLevel = (data['pH'] as num?)?.toDouble() ?? pHLevel;
                turbidityLevel =
                    (data['turbidity'] as num?)?.toDouble() ?? turbidityLevel;
                webSocketStatus =
                    "✅ Connected. Temp: $TemperatureLevel°C, pH: $pHLevel, Turbidity: $turbidityLevel NTU";
              });
            }
          } else {
            debugPrint("⚠️ Unexpected WebSocket message format: $jsonData");
            setState(() {
              webSocketStatus = "⚠️ Device failure.";
            });
          }
        } catch (e) {
          debugPrint("❌ Error parsing WebSocket data: $e");
          setState(() {
            webSocketStatus = "❌ Invalid data format received.";
          });
        }
      },
      onError: (error) {
        debugPrint("❌ WebSocket Error: $error}");
        setState(() {
          webSocketStatus = "❌ Network failed. Please check your connection.";
        });
      },
      onDone: () {
        debugPrint("🔌 WebSocket connection closed.");
        setState(() {
          webSocketStatus = "🔌 WebSocket connection closed.";
        });
      },
      cancelOnError: true,
    );
  }

  // void _listenToWebSocket() {
  //   debugPrint("🔌 Connecting ...");

  //   setState(() {
  //     webSocketStatus = "🔌 Connecting ...";
  //   });

  //   channel.stream.listen(
  //         (message) {
  //       debugPrint("📩 Received Raw WebSocket Message: $message");

  //       try {
  //         Map<String, dynamic> jsonData = jsonDecode(message);
  //         if (jsonData['type'] == 'sensor' &&
  //             jsonData['data'] is Map<String, dynamic>) {
  //           Map<String, dynamic> data = jsonData['data'];

  //           List<String> missingFields = [];
  //           List<String> invalidFields = [];

  //           if (!data.containsKey('temperature')) missingFields.add('Temperature');
  //           if (!data.containsKey('pH')) missingFields.add('pH');
  //           if (!data.containsKey('turbidity')) missingFields.add('Turbidity');

  //           if (missingFields.isNotEmpty) {
  //             debugPrint("⚠️ Missing sensor data: ${missingFields.join(', ')}");

  //             setState(() {
  //               webSocketStatus =
  //               "⚠️ Device failure: Missing data from ${missingFields.join(', ')} sensor(s).";
  //             });
  //           } else {
  //             setState(() {
  //               TemperatureLevel =
  //                   (data['temperature'] as num?)?.toDouble() ?? TemperatureLevel;
  //               pHLevel =
  //                   (data['pH'] as num?)?.toDouble() ?? pHLevel;
  //               turbidityLevel =
  //                   (data['turbidity'] as num?)?.toDouble() ?? turbidityLevel;
  //               webSocketStatus =
  //               "✅ Connected. Temp: $TemperatureLevel°C, pH: $pHLevel, Turbidity: $turbidityLevel NTU";
  //             });
  //           }
  //         } else {
  //           debugPrint("⚠️ Unexpected WebSocket message format: $jsonData");
  //           setState(() {
  //             webSocketStatus =
  //             "⚠️ Device failure.";
  //           });
  //         }

  //       } catch (e) {
  //         debugPrint("❌ Error parsing WebSocket data: $e");
  //       }
  //     },
  //     onError: (error) {
  //       debugPrint("❌ WebSocket Error: $error");
  //       setState(() {
  //         webSocketStatus =
  //         "❌ Network failed. Please check your connection.";
  //       });
  //     },
  //     onDone: () {
  //       debugPrint("🔌 WebSocket connection closed.");
  //       setState(() {
  //         webSocketStatus =
  //         "🔌 WebSocket connection closed.";
  //       });
  //     },
  //     cancelOnError: true,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title:
            _isSearching
                ? SearchField(_searchController, _filterItems)
                : const Text(
                  "Dashboard",
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
        child:
            _isSearching
                ? _buildSearchResults()
                : Column(
                  children: [
                    _buildWebSocketStatus(), // ✅ NEW
                    Expanded(child: _buildDashboard()),
                  ],
                ),
      ),
    );
  }

  Widget _buildWebSocketStatus() {
    Color color;

    if (webSocketStatus.startsWith("✅")) {
      color = Colors.greenAccent;
    } else if (webSocketStatus.startsWith("⚠️")) {
      color = Colors.orangeAccent;
    } else if (webSocketStatus.startsWith("❌")) {
      color = Colors.redAccent;
    } else {
      color = Colors.white;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black.withOpacity(0.3),
      child: Text(
        webSocketStatus,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
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
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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

  Widget _buildDashboard() {
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
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildInfoCard(
                    Icons.thermostat,
                    "$TemperatureLevel°C",
                    Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoCard(
                    Icons.opacity,
                    "$turbidityLevel NTU",
                    Colors.orangeAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoCard(
                    Icons.science,
                    "$pHLevel",
                    Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DashboardRow(
              Icons.thermostat,
              "Temperature",
              Colors.redAccent,
              Temperature(temperature: TemperatureLevel),
              Icons.opacity,
              "Turbidity",
              Colors.orangeAccent,
              Turbidity(turbidity: turbidityLevel),
            ),
            DashboardRow(
              Icons.science,
              "pH",
              Colors.pink,
              PHLevel(pH: pHLevel),
              Icons.timer,
              "Schedule Feed",
              Colors.redAccent,
              Schedulefeed(),
            ),
            DashboardRow(
              FontAwesomeIcons.fish,
              "See Fish Activity",
              Colors.indigo,
              SeefishScreen(),
              FontAwesomeIcons.bell,
              "Check Notifications",
              Colors.pinkAccent,
              FishAlertWidget(),
            ),
            // DashboardCard(FontAwesomeIcons.bell, "Check Notifications",
            //     Colors.pinkAccent, FishAlertWidget()),
            DashboardCard(
              Icons.wifi,
              "Change Wi-Fi",
              Colors.teal,
              ChangeWiFiScreen(),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: Colors.white54),
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

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Widget screen;

  const DashboardCard(
    this.icon,
    this.label,
    this.color,
    this.screen, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: SizedBox(
        width: screenWidth / 2 - 24,
        height: 120,
        child: Card(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          margin: const EdgeInsets.all(1),
          child: Center(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Ensures tight fit around content
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
