import 'package:flutter/material.dart';

import 'login_screen.dart'; // Import the login screen

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'Welcome to the Dashboard!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
        ElevatedButton(
          onPressed: () {
            // Navigate to the dashboard after login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }, child: const Text('Logout'),),
          ],
        ),
      ),
    );
  }
}
