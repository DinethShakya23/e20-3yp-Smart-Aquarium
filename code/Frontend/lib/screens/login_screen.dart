import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:frontend/screens/dashboard_screen.dart';
import '../widgets/custom_button.dart';
import 'registration_screen.dart'; // Import the registration screen
import '../widgets/Dividerwithtext.dart';
import 'Forget_password.dart';
import '../widgets/Password_filed.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

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
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(100.0), // Adjust the radius as needed
                child: Image.asset(
                  'assert/images/Logo00.jpg',
                  width: 86,
                  height: 86,
                  fit: BoxFit.cover, // Ensures the image scales properly
                ),
              ),
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
                obscureText: false,
                controller: emailController,
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
              CustomPasswordField(
                label: "Password",
                prefixIcon: Icons.lock,
                controller: passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgetPassword()),
                  );
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: "Login",
                fontSize: 30,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                onPressed: () async {
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  try {
                    final response = await http.post(
                      Uri.parse('http://192.168.3.244:3001/api/login'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({'email': email, 'password': password}),
                    );

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Login successfully!")),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DashBoard()),
                      );
                    } else {
                      print(response.statusCode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Email or Password Incorrect")),
                      );
                    }
                  } catch (e, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("An error occurred: ${e.toString()}")),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              const DividerWithText(
                text: "Or Login with",
                lineColor: Color(0xFFD0F0FF),
                thickness: 3.0,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.facebook,
                    color: Color(0xFF1e52e6),
                    size: 55.0,
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  const Icon(
                    Icons.apple,
                    size: 55.0,
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  Image.asset('assert/images/Google_logo.png',
                      width: 55, height: 55),
                ],
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  children: [
                    TextSpan(text: "Don't have an account?  "),
                    TextSpan(
                      text: "Register", // clickable text
                      style: TextStyle(
                        color: Color.fromRGBO(30, 120, 190, 1),
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegistrationScreen(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
