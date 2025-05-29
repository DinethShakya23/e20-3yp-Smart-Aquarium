import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const PHChartApp());

class PHChartApp extends StatelessWidget {
  const PHChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PHChartPage(),
    );
  }
}

class PHChartPage extends StatefulWidget {
  @override
  _PHChartPageState createState() => _PHChartPageState();
}

class _PHChartPageState extends State<PHChartPage> {
  Map<String, dynamic> data = {};
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchPHData();
  }

  Future<void> fetchPHData() async {
    final url = Uri.parse("http://10.0.2.2:3001/api/pH/hourly-ph");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          data = jsonData;
          selectedDate = jsonData.keys.first;
        });
      } else {
        loadFallbackJson();
      }
    } catch (e) {
      loadFallbackJson();
    }
  }

  void loadFallbackJson() {
    String jsonString = '''
    {
      "2025-05-1": [
        {"time": "00:00", "ph": 7.1},
        {"time": "01:00", "ph": 7.2},
        {"time": "02:00", "ph": 7.0},
        {"time": "03:00", "ph": 6.9},
        {"time": "04:00", "ph": 7.0},
        {"time": "05:00", "ph": 7.1},
        {"time": "06:00", "ph": 7.2},
        {"time": "07:00", "ph": 7.3},
        {"time": "08:00", "ph": 7.2},
        {"time": "09:00", "ph": 7.1},
        {"time": "10:00", "ph": 7.0},
        {"time": "11:00", "ph": 6.9},
        {"time": "12:00", "ph": 6.8},
        {"time": "13:00", "ph": 6.9},
        {"time": "14:00", "ph": 7.0},
        {"time": "15:00", "ph": 7.1},
        {"time": "16:00", "ph": 7.3},
        {"time": "17:00", "ph": 7.2},
        {"time": "18:00", "ph": 7.1},
        {"time": "19:00", "ph": 7.0},
        {"time": "20:00", "ph": 6.9},
        {"time": "21:00", "ph": 6.8},
        {"time": "22:00", "ph": 6.9},
        {"time": "23:00", "ph": 7.0}
      ]
    }
    ''';

    final jsonData = json.decode(jsonString);
    setState(() {
      data = jsonData;
      selectedDate = jsonData.keys.first;
    });
  }

  List<FlSpot> getSpotsForDate(String date) {
    if (!data.containsKey(date)) return [];
    return List<Map<String, dynamic>>.from(data[date]).map((entry) {
      int hour = int.parse(entry['time'].split(":")[0]);
      double ph = entry['ph'].toDouble();
      return FlSpot(hour.toDouble(), ph);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spots = getSpotsForDate(selectedDate);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removed the back button
        title: Text("pH Chart - $selectedDate"),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.parse(selectedDate),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (pickedDate != null) {
                final formatted = DateFormat('yyyy-MM-dd').format(pickedDate);
                if (data.containsKey(formatted)) {
                  setState(() => selectedDate = formatted);
                }
              }
            },
          ),
        ],
      ),
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false, interval: 0.5),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 3,
                        getTitlesWidget: (value, _) =>
                            Text(value.toInt().toString()),
                      ),
                    ),
                  ),
                  minX: 0,
                  maxX: 23,
                  minY: 2,
                  maxY: 13,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 4,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: true),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
