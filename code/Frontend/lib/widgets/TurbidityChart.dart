import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Main entry point for the turbidity chart screen
void main() => runApp(const TurbidityChartApp());

class TurbidityChartApp extends StatelessWidget {
  const TurbidityChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TurbidityChartPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TurbidityChartPage extends StatefulWidget {
  @override
  _TurbidityChartPageState createState() => _TurbidityChartPageState();
}

class _TurbidityChartPageState extends State<TurbidityChartPage> {
  Map<String, dynamic> data = {};
  // ADJUSTMENT 1: Adds 5 hours to the initial date for fetching
  String selectedDate = DateFormat(
    'yyyy-MM-dd',
  ).format(DateTime.now().add(const Duration(hours: 5)));
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTurbidityData();
  }

  /// Fetches hourly turbidity data from the server.
  Future<void> fetchTurbidityData() async {
    // ADJUSTMENT 1: Adds 5 hours to the 'today' check
    final String today = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now().add(const Duration(hours: 5)));
    final url = Uri.parse(
      "http://18.140.68.45:3001/api/turbidity/hourly-turbidity",
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("✅ Turbidity data fetched from backend: ${jsonData.keys}");

        if (mounted) {
          setState(() {
            data = jsonData;
            // Check if data for today exists. If not, fallback to the first available date.
            if (!jsonData.containsKey(today) && jsonData.keys.isNotEmpty) {
              selectedDate = jsonData.keys.first; // Fallback to the first date
              // Let the user know we're showing a different date
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "No data for today. Showing data for $selectedDate",
                      ),
                    ),
                  );
                }
              });
            } else {
              selectedDate = today; // Stick with today's date
            }
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
      print("❌ Error fetching turbidity data: $e. Loading fallback...");
      loadFallbackJson();
    }
  }

  /// Loads a hardcoded set of sample data if the network request fails.
  void loadFallbackJson() {
    // ADJUSTMENT 1: Adds 5 hours to the fallback's 'today' check
    final String today = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now().add(const Duration(hours: 5)));
    String jsonString = '''
    {
      "2025-07-10": [
        {"time": "00:00", "turbidity": 4.3}, {"time": "01:00", "turbidity": 1.8},
        {"time": "02:00", "turbidity": 2.1}, {"time": "03:00", "turbidity": 1.7},
        {"time": "04:00", "turbidity": 1.5}, {"time": "05:00", "turbidity": 2.6},
        {"time": "06:00", "turbidity": 2.3}, {"time": "07:00", "turbidity": 1.9},
        {"time": "08:00", "turbidity": 2.4}, {"time": "09:00", "turbidity": 2.8},
        {"time": "10:00", "turbidity": 3.1}, {"time": "11:00", "turbidity": 3.3},
        {"time": "12:00", "turbidity": 3.6}, {"time": "13:00", "turbidity": 3.2},
        {"time": "14:00", "turbidity": 2.9}, {"time": "15:00", "turbidity": 2.5},
        {"time": "16:00", "turbidity": 2.2}, {"time": "17:00", "turbidity": 1.8},
        {"time": "18:00", "turbidity": 1.6}, {"time": "19:00", "turbidity": 2.0},
        {"time": "20:00", "turbidity": 2.4}, {"time": "21:00", "turbidity": 1.7},
        {"time": "22:00", "turbidity": 1.4}, {"time": "23:00", "turbidity": 1.1}
      ]
    }
    ''';

    if (mounted) {
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      print("📦 Loaded fallback turbidity JSON keys: ${jsonData.keys}");
      setState(() {
        data = jsonData;
        // Check if data for today exists in the fallback. If not, use the first key.
        if (!jsonData.containsKey(today) && jsonData.keys.isNotEmpty) {
          selectedDate = jsonData.keys.first;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "No data for today. Showing fallback for $selectedDate",
                  ),
                ),
              );
            }
          });
        } else {
          selectedDate = today;
        }
        isLoading = false;
      });
    }
  }

  /// Converts the raw data for a given date into a list of FlSpot for the chart.
  List<FlSpot> getSpotsForDate(String date) {
    if (!data.containsKey(date)) return [];
    final entries = List<Map<String, dynamic>>.from(data[date]);
    return entries.map((entry) {
      int originalHour = int.parse(entry['time'].split(":")[0]);
      double turb = (entry['turbidity'] as num).toDouble();

      // --- ADJUSTMENT 2: SHIFT DATA DISPLAY TIME ---
      // Add 5 hours and use the modulo operator (%) to wrap around the 24-hour clock.
      int adjustedHour = (originalHour + 5) % 24;
      // --- END OF ADJUSTMENT ---

      return FlSpot(adjustedHour.toDouble(), turb);
    }).toList();
  }

  /// Calculates the Y-axis range dynamically based on the data.
  Map<String, double> getChartBounds(List<FlSpot> spots) {
    if (spots.isEmpty) return {'minY': 0, 'maxY': 50}; // Default range

    double maxVal = 0;
    for (var spot in spots) {
      if (spot.y > maxVal) maxVal = spot.y;
    }
    // Add some padding to the top
    return {'minY': 0, 'maxY': (maxVal + 2).ceilToDouble()};
  }

  /// Shows a date picker to select a different day.
  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      // ADJUSTMENT 1: Adds 5 hours to the date picker's initial date
      initialDate:
          DateTime.tryParse(selectedDate) ??
          DateTime.now().add(const Duration(hours: 5)),
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
    final bounds = getChartBounds(spots);

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
            "Turbidity - $selectedDate",
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
                                      const RotatedBox(
                                        quarterTurns: -1,
                                        child: Text(
                                          "Turbidity (NTU)",
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
                                                  showTitles: true,
                                                  interval: 5,
                                                  getTitlesWidget:
                                                      (value, meta) => Text(
                                                        value
                                                            .toInt()
                                                            .toString(),
                                                      ),
                                                  reservedSize: 40,
                                                ),
                                              ),
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
                                            minY: bounds['minY'],
                                            maxY: bounds['maxY'],
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
