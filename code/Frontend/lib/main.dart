import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
//import 'screens/login_screen.dart'; // Import the login screen
import 'screens/dashboard_screen.dart'; // Import the splash screen
//import 'screens/registration_screen.dart'; // Import the registration screen

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Aquarium',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashBoard(userEmail: 'janith12@gmail.com'), // Show Splash Screen first
    );
  }
}
