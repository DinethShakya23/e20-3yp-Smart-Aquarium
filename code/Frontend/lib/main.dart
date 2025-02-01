import 'package:flutter/material.dart';

import 'screens/login_screen.dart'; // Import the login screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Aquarium',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Set the initial screen to LoginScreen
    );
  }
}
