import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'package:flutter/gestures.dart';
import 'login_screen.dart'; //// Import the login screen
import '../widgets/Password_filed.dart';
import 'package:http/http.dart' as http;

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController passwordControllerconform =
        TextEditingController();
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      body: Builder(builder: (context) {
        return Container(
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
                  borderRadius: BorderRadius.circular(
                      100.0), // Adjust the radius as needed
                  child: Image.asset(
                    'assert/images/Logo00.jpg',
                    width: 86,
                    height: 86,
                    fit: BoxFit.cover, // Ensures the image scales properly
                  ),
                ),
                SizedBox(
                  width: 500,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Create an account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController, // Add controller here
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100)),
                    prefixIcon: const Icon(Icons.email),
                    fillColor: Colors.white,
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),
                const SizedBox(height: 10),
                CustomPasswordField(
                  label: "Password",
                  prefixIcon: Icons.lock,
                  controller: passwordController,
                  isPassword: true,
                ),
                const SizedBox(height: 10),
                CustomPasswordField(
                  label: "Confirm Password",
                  prefixIcon: Icons.lock,
                  controller: passwordControllerconform,
                  isPassword: true,
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: "Create Account",
                  fontSize: 20,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  onPressed: () async {
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();
                    String confirmPassword =
                        passwordControllerconform.text.trim();

                    if (email.isEmpty ||
                        password.isEmpty ||
                        confirmPassword.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    if (password != confirmPassword) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Passwords do not match")),
                      );
                      return;
                    }

                    try {
                      final response = await http.post(
                        Uri.parse(
                            'http://98.84.177.58:3001/api/register'), //http://13.53.127.196:8080/  192.168.59.89
                        headers: {'Content-Type': 'application/json'},
                        body:
                            jsonEncode({'email': email, 'password': password}),
                      );

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Account created successfully!")),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      } else {
                        print(response.statusCode);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Failed to create account")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("An error occurred: ${e.toString()}")),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Divider(
                  color: Color(0xFFD0F0FF),
                  thickness: 3.0,
                ),
                const Text(
                  "Or Login with",
                  style: TextStyle(
                    color: Color(0xFFD0F0FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(
                  color: Color(0xFFD0F0FF),
                  thickness: 3.0,
                ),
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
                      TextSpan(text: "Already have an account? "),
                      TextSpan(
                        text: "Login", // clickable text
                        style: TextStyle(
                          color: Color.fromRGBO(30, 120, 190, 1),
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
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
        );
      }),
    );
  }
}
