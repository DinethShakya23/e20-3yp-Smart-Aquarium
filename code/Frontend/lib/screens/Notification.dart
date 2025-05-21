import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class FishAlertWidget extends StatefulWidget {
  const FishAlertWidget({super.key});

  @override
  _FishAlertWidgetState createState() => _FishAlertWidgetState();
}

class _FishAlertWidgetState extends State<FishAlertWidget> {
  final WebSocketChannel channel =
  IOWebSocketChannel.connect('ws://10.0.2.2:8765');
  final List<Map<String, dynamic>> _alerts = [];
  bool _usingDummyData = false;
  bool _connected = false;

  final List<Map<String, dynamic>> dummyAlerts = [
    {
      "track_id": 1,
      "type": "High Activity",
      "timestamp": 1716000000,
    },
    {
      "track_id": 2,
      "type": "No Movement",
      "timestamp": 1716000300,
    },
    {
      "track_id": 3,
      "type": "Erratic Swimming",
      "timestamp": 1716000600,
    },
  ];

  @override
  void initState() {
    super.initState();

    // Send ping to check server
    channel.sink.add(jsonEncode({"ping": true}));

    channel.stream.listen(
          (data) {
        final decoded = jsonDecode(data);

        // Respond to ping acknowledgement
        if (decoded is Map && decoded['status'] == 'connected') {
          setState(() {
            _connected = true;
          });
          return;
        }

        // Handle alerts
        setState(() {
          _alerts.insert(0, decoded);
          _usingDummyData = false;
          _connected = true;
        });
      },
      onError: (_) {
        _loadDummyData();
        setState(() {
          _connected = false;
        });
      },
      onDone: () {
        _loadDummyData();
        setState(() {
          _connected = false;
        });
      },
    );
  }



  void _loadDummyData() {
    if (_alerts.isEmpty && !_usingDummyData) {
      setState(() {
        _alerts.addAll(dummyAlerts);
        _usingDummyData = true;
      });
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Behavior Alerts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Return to Dashboard',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              _connected ? Icons.wifi : Icons.wifi_off,
              color: _connected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            color: _connected ? Colors.green[100] : Colors.red[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _connected ? Icons.check_circle : Icons.error,
                  color: _connected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _connected
                      ? 'Connected to WebSocket'
                      : 'Disconnected / Using dummy data',
                  style: TextStyle(
                    color: _connected ? Colors.green[900] : Colors.red[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _alerts.isEmpty
                ? const Center(
              child: Text(
                'No alerts yet',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: Text(
                        alert['track_id'].toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      "Track ID: ${alert['track_id']}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      "Alert: ${alert['type']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: Text(
                      "${DateTime.fromMillisecondsSinceEpoch((alert['timestamp'] * 1000).toInt())}",
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
