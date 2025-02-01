import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/custom_button.dart';
import 'dashboard_screen.dart'; // Import the dashboard screen
import 'registration_screen.dart'; // Import the registration screen
import '../widgets/Dividerwithtext.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0468BF), Color(0xFFA1D6F3)], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assert/images/Logo_Icon.jpg',
                  width: 100, height: 100),
              const SizedBox(height: 20),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD0F0FF),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100)),
                  prefixIcon: const Icon(Icons.email),
                  fillColor: Colors.white, // Set background color
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100)),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: const Icon(Icons.visibility),
                  fillColor: Colors.white, // Set background color
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: "Login",
                fontSize: 30,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                onPressed: () {
                  // Handle registration
                  // Navigate to the registration screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegistrationScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              const DividerWithText(
                text: "Or Login with",
                lineColor: Color(0xFFD0F0FF),
                thickness: 3.0,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.facebook,
                    color: Color(0xFF1e52e6),
                    size: 55.0,
                  ),
                  const SizedBox(width: 25,),
                  const Icon(
                    Icons.apple,
                    size: 55.0,
                  ),
                  const SizedBox(width: 25,),
                  Image.asset('assert/images/Google_logo.png',
                      width: 55, height: 55),
                ],
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: "Don't have an account? Register",
                onPressed: () {
                  // Handle registration
                  // Navigate to the registration screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegistrationScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
