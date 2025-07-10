import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Main entry point for the pH chart screen
void main() => runApp(const PHChartApp());

class PHChartApp extends StatelessWidget {
  const PHChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: PHChartPage(), debugShowCheckedModeBanner: false);
  }
}

class PHChartPage extends StatefulWidget {
  @override
  _PHChartPageState createState() => _PHChartPageState();
}

class _PHChartPageState extends State<PHChartPage> {
  Map<String, dynamic> data = {};
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPHData();
  }

  /// Fetches hourly pH data from the server.
  Future<void> fetchPHData() async {
    // Correct endpoint for hourly pH data
    final url = Uri.parse("http://18.140.68.45:3001/api/pH/hourly-ph");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("✅ Data fetched from backend: ${jsonData.keys}");

        if (mounted) {
          setState(() {
            data = jsonData;
            // Set to the first available date or handle empty data
            selectedDate =
                data.keys.isNotEmpty
                    ? data.keys.first
                    : DateFormat('yyyy-MM-dd').format(DateTime.now());
            isLoading = false;
          });
        }
      } else {
        print(
          "⚠ Server responded with status ${response.statusCode}, loading fallback data...",
        );
        loadFallbackJson();
      }
    } catch (e) {
      print("❌ Error fetching pH data: $e. Loading fallback...");
      loadFallbackJson();
    }
  }

  /// Loads a hardcoded set of sample data if the network request fails.
  void loadFallbackJson() {
    String jsonString = '''
    {
      "2025-07-10": [
        {"time": "00:00", "ph": 7.1}, {"time": "01:00", "ph": 7.2},
        {"time": "02:00", "ph": 7.0}, {"time": "03:00", "ph": 6.9},
        {"time": "04:00", "ph": 7.0}, {"time": "05:00", "ph": 7.1},
        {"time": "06:00", "ph": 7.2}, {"time": "07:00", "ph": 7.3},
        {"time": "08:00", "ph": 7.2}, {"time": "09:00", "ph": 7.1},
        {"time": "10:00", "ph": 7.0}, {"time": "11:00", "ph": 6.9},
        {"time": "12:00", "ph": 6.8}, {"time": "13:00", "ph": 6.9},
        {"time": "14:00", "ph": 7.0}, {"time": "15:00", "ph": 7.1},
        {"time": "16:00", "ph": 7.3}, {"time": "17:00", "ph": 7.2},
        {"time": "18:00", "ph": 7.1}, {"time": "19:00", "ph": 7.0},
        {"time": "20:00", "ph": 6.9}, {"time": "21:00", "ph": 6.8},
        {"time": "22:00", "ph": 6.9}, {"time": "23:00", "ph": 7.0}
      ]
    }
    ''';

    if (mounted) {
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      print("📦 Loaded fallback pH JSON keys: ${jsonData.keys}");
      setState(() {
        data = jsonData;
        selectedDate = jsonData.keys.first;
        isLoading = false;
      });
    }
  }

  /// Converts the raw data for a given date into a list of FlSpot for the chart.
  List<FlSpot> getSpotsForDate(String date) {
    if (!data.containsKey(date)) return [];
    final entries = List<Map<String, dynamic>>.from(data[date]);
    return entries.map((entry) {
      int hour = int.parse(entry['time'].split(":")[0]);
      double ph = (entry['ph'] as num).toDouble();
      return FlSpot(hour.toDouble(), ph);
    }).toList();
  }

  /// Shows a date picker to select a different day.
  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(selectedDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(pickedDate);
      if (data.containsKey(formatted)) {
        setState(() => selectedDate = formatted);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("No data for $formatted")));
      }
    }
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
            "pH Level - $selectedDate",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              onPressed: isLoading ? null : _selectDate,
            ),
          ],
        ),
        body:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
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
                                      // ✅ MODIFIED: Rotated title moved back to the left
                                      const RotatedBox(
                                        quarterTurns:
                                            -1, // Rotated for left side
                                        child: Text(
                                          "pH Value",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Chart is now the second element
                                      Expanded(
                                        child: LineChart(
                                          LineChartData(
                                            gridData: FlGridData(show: true),
                                            // ✅ MODIFIED: Titles data updated
                                            titlesData: FlTitlesData(
                                              // Show left titles
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  interval: 1,
                                                  getTitlesWidget:
                                                      (value, meta) => Text(
                                                        value.toStringAsFixed(
                                                          1,
                                                        ),
                                                      ),
                                                  reservedSize: 40,
                                                ),
                                              ),
                                              // Hide right titles
                                              rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
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
                                              topTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
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
                                            minY: 5, // pH specific range
                                            maxY: 9, // pH specific range
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
