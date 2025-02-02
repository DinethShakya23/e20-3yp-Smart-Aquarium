import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,  
      end: Alignment.bottomCenter,  
            colors: [
        Color(0xFF034264),  
        Color(0xFF329EFD),  
        Color(0xFFB7E6F6),  
      ],
      stops: [0.0, 0.5, 1.0],
            
          ),
        ),
        
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children: [
              const SizedBox(height: 140),
              ClipRRect(
                        borderRadius: BorderRadius.circular(100.0), // Adjust the radius as needed
                        child: Image.asset(
                          'assert/images/Logo00.jpg',
                          width: 86,
                          height: 86,
                          fit: BoxFit.cover, // Ensures the image scales properly
                        ),
                      ),
              
              const SizedBox(height: 20),
              const Text(
                'AquaSense',
                style: TextStyle(
                  fontFamily: 'urbanist',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              //const SizedBox(height: 0),
              SizedBox(
                width: 200,
                child : const Text(
                  textAlign: TextAlign.center,
                  'Your Personal Aquarium Assistant',
                  style: TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )
                )
              ),
    
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                
              ),

              const SizedBox(height: 100),
              Container(
                width: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), // not working
                ), 

                child: CustomButton(
                  fontFamily: 'urbanist',
                  text: "Register",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegistrationScreen()),
                    );
                  }
                )
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(
                      fontFamily:'urbanist',
                      //fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color.fromARGB(202, 0, 0, 0)                )
                    ),
                   ], 
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontFamily: 'urbanist',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E78BE),
                      ),
                    ),
                  ),
                 ],
              ),
              
              
            ],
          ),
        ),
      ),
    );
  }
}
