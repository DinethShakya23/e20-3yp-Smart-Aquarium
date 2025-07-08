import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const TurbidityChartApp());

class TurbidityChartApp extends StatelessWidget {
  const TurbidityChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TurbidityChartPage(),
    );
  }
}

class TurbidityChartPage extends StatefulWidget {
  @override
  _TurbidityChartPageState createState() => _TurbidityChartPageState();
}

class _TurbidityChartPageState extends State<TurbidityChartPage> {
  Map<String, dynamic> data = {};
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchTurbidityData();
  }

  Future<void> fetchTurbidityData() async {
    final url =
        Uri.parse("http://18.140.68.453001/api/turbidity/hourly-turbidity");

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
      "2025-05-01": [
        {"time": "00:00", "turbidity": 4.3},
        {"time": "01:00", "turbidity": 1.8},
        {"time": "02:00", "turbidity": 2.1},
        {"time": "03:00", "turbidity": 1.7},
        {"time": "04:00", "turbidity": 1.5},
        {"time": "05:00", "turbidity": 2.6},
        {"time": "06:00", "turbidity": 2.3},
        {"time": "07:00", "turbidity": 1.9},
        {"time": "08:00", "turbidity": 2.4},
        {"time": "09:00", "turbidity": 2.8},
        {"time": "10:00", "turbidity": 3.1},
        {"time": "11:00", "turbidity": 3.3},
        {"time": "12:00", "turbidity": 3.6},
        {"time": "13:00", "turbidity": 3.2},
        {"time": "14:00", "turbidity": 2.9},
        {"time": "15:00", "turbidity": 2.5},
        {"time": "16:00", "turbidity": 2.2},
        {"time": "17:00", "turbidity": 1.8},
        {"time": "18:00", "turbidity": 1.6},
        {"time": "19:00", "turbidity": 2.0},
        {"time": "20:00", "turbidity": 2.4},
        {"time": "21:00", "turbidity": 1.7},
        {"time": "22:00", "turbidity": 1.4},
        {"time": "23:00", "turbidity": 1.1}
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
      double turb = entry['turbidity'].toDouble();
      return FlSpot(hour.toDouble(), turb);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spots = getSpotsForDate(selectedDate);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        title: Text("Turbidity Chart - $selectedDate"),
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
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.deepPurple,
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
