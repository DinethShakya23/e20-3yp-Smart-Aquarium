import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChangeWiFiScreen extends StatefulWidget {
  const ChangeWiFiScreen({super.key});

  @override
  State<ChangeWiFiScreen> createState() => _ChangeWiFiScreenState();
}

class _ChangeWiFiScreenState extends State<ChangeWiFiScreen> {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String message = "";

  Future<void> changeWiFi() async {
    final ssid = ssidController.text.trim();
    final password = passwordController.text.trim();

    if (ssid.isEmpty || password.isEmpty) {
      setState(() {
        message = "Please enter both SSID and password.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      final response = await http.post(
        Uri.parse(
            "http://10.0.2.2:3001/api/change-wifi"), // Replace with your Pi's IP
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ssid": ssid,
          "password": password,
          "pi_ip": "192.168.1.50" // Optional: Let user choose if needed
        }),
      );

      setState(() {
        isLoading = false;
        if (response.statusCode == 200) {
          message = "✅ Wi-Fi change request sent successfully!";
        } else {
          message = "❌ Failed: ${response.body}";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        message = "❌ Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Change Wi-Fi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey.shade900,
        elevation: 4.0,
        shadowColor: Colors.blueGrey.shade500,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0468BF), Color(0xFFA1D6F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Image.asset(
                  'assert/images/Logo00.jpg',
                  width: 86,
                  height: 86,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: ssidController,
                decoration: InputDecoration(
                  labelText: "Wi-Fi SSID",
                  prefixIcon: const Icon(Icons.wifi),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100)),
                  fillColor: Colors.white,
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Wi-Fi Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100)),
                  fillColor: Colors.white,
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: isLoading ? null : changeWiFi,
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue))
                    : const Text(
                        "Apply Wi-Fi",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
