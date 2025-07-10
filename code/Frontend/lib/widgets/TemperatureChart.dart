import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(TemperatureChartApp());

class TemperatureChartApp extends StatelessWidget {
  const TemperatureChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TemperatureChartPage());
  }
}

class TemperatureChartPage extends StatefulWidget {
  @override
  _TemperatureChartPageState createState() => _TemperatureChartPageState();
}

class _TemperatureChartPageState extends State<TemperatureChartPage> {
  Map<String, dynamic> data = {};
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchTemperatureData();
  }

  Future<void> fetchTemperatureData() async {
    final url = Uri.parse("http://18.140.68.45:3001/api/temperature/hourly");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("✅ Data fetched from backend: ${jsonData.keys}");

        setState(() {
          data = jsonData;
          selectedDate = jsonData.keys.first;
        });
      } else {
        print(
          "⚠ Server responded with status ${response.statusCode}, loading fallback data...",
        );
        loadFallbackJson();
      }
    } catch (e) {
      print("❌ Error fetching data: $e. Loading fallback...");
      loadFallbackJson();
    }
  }

  void loadFallbackJson() {
    String jsonString = '''
    {
      "2025-05-01": [
        {"time": "00:00", "temperature": 24},
        {"time": "01:00", "temperature": 23.5},
        {"time": "02:00", "temperature": 23},
        {"time": "03:00", "temperature": 22.5},
        {"time": "04:00", "temperature": 22},
        {"time": "05:00", "temperature": 21.5},
        {"time": "06:00", "temperature": 22},
        {"time": "07:00", "temperature": 23},
        {"time": "08:00", "temperature": 25},
        {"time": "09:00", "temperature": 26},
        {"time": "10:00", "temperature": 27},
        {"time": "11:00", "temperature": 28},
        {"time": "12:00", "temperature": 29},
        {"time": "13:00", "temperature": 30},
        {"time": "14:00", "temperature": 30.5},
        {"time": "15:00", "temperature": 31},
        {"time": "16:00", "temperature": 30},
        {"time": "17:00", "temperature": 29},
        {"time": "18:00", "temperature": 28},
        {"time": "19:00", "temperature": 27},
        {"time": "20:00", "temperature": 26},
        {"time": "21:00", "temperature": 25},
        {"time": "22:00", "temperature": 24},
        {"time": "23:00", "temperature": 23}
      ]
    }
    ''';

    final Map<String, dynamic> jsonData = json.decode(jsonString);
    print("📦 Loaded fallback JSON keys: ${jsonData.keys}");

    setState(() {
      data = jsonData;
      selectedDate = jsonData.keys.first;
    });
  }

  List<FlSpot> getSpotsForDate(String date) {
    if (!data.containsKey(date)) return [];

    final entries = List<Map<String, dynamic>>.from(data[date]);
    return entries.map((entry) {
      int hour = int.parse(entry['time'].split(":")[0]);
      double temp = entry['temperature'].toDouble();
      return FlSpot(hour.toDouble(), temp);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spots = getSpotsForDate(selectedDate);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0468BF), Color(0xFFA1D6F3)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Temperature - $selectedDate",
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.white),
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No data for $formatted")),
                    );
                  }
                }
              },
            ),
          ],
        ),
        body:
            data.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.white.withOpacity(0.9),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      const RotatedBox(
                                        quarterTurns: -1,
                                        child: Text(
                                          "Temperature (°C)",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: LineChart(
                                          LineChartData(
                                            gridData: FlGridData(show: true),
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                  interval: 2,
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  interval: 3,
                                                  getTitlesWidget: (
                                                    value,
                                                    meta,
                                                  ) {
                                                    return Text(
                                                      value.toInt().toString(),
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: true,
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1,
                                              ),
                                            ),
                                            minX: 0,
                                            maxX: 23,
                                            minY: 5,
                                            maxY: 40,
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: spots,
                                                isCurved: true,
                                                color: const Color(0xFF0468BF),
                                                barWidth: 4,
                                                dotData: FlDotData(show: true),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      const Color(
                                                        0xFF0468BF,
                                                      ).withOpacity(0.4),
                                                      const Color(
                                                        0xFFA1D6F3,
                                                      ).withOpacity(0.1),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Time (Hours)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
