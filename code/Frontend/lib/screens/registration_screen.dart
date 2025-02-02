import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'package:flutter/gestures.dart';
import 'login_screen.dart'; //// Import the login screen
import '../widgets/Password_filed.dart';


class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController passwordControllerconform = TextEditingController();
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
                        borderRadius: BorderRadius.circular(100.0), // Adjust the radius as needed
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
                obscureText: false,
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

              RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 0, 0, 0),  
                ),
                children: [
                  TextSpan(text: "Already have an account? "),  
                  TextSpan(
                    text: "Login",  // clickable text
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
      ),
    );
  }
}
