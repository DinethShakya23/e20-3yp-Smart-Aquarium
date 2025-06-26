import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import 'dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;

  const ProfileScreen({Key? super.key, required this.userEmail});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  String phone = "";
  String location = "";
  String imageUrl = "https://i.pravatar.cc/300"; // Default placeholder image
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = "Failed to load profile";

  @override
  void initState() {
    super.initState();
    _getUserEmailAndFetchProfile();
  }

  Future<void> _getUserEmailAndFetchProfile() async {
    String userEmail = widget.userEmail;

    // If no email was passed, try to get it from shared preferences
    if (userEmail.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      userEmail = prefs.getString('userEmail') ?? '';
    }

    if (userEmail.isNotEmpty) {
      _fetchProfile(userEmail);
    } else {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = "No user email found. Please log in again.";
      });
    }
  }

  Future<void> _fetchProfile(String userEmail) async {
    final uri = Uri.parse(
        'http://10.0.2.2:3001/api/profile/${Uri.encodeComponent(userEmail)}');

    try {
      final response = await http.get(uri);
      print("Fetching profile for $userEmail");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          phone = data['phone'] ?? '';
          location = data['location'] ?? '';

          // Handle image URL properly
          final img = data['image_url'];
          if (img != null && img.isNotEmpty) {
            imageUrl = 'http://10.0.2.2:3001/uploads/$img';
            print("Image URL set to: $imageUrl");
          } else {
            print("No image URL found in profile data");
          }

          isLoading = false;
        });
      } else {
        print("Error status code: ${response.statusCode}");
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Failed to load profile: ${response.statusCode}';
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error fetching profile: $e';
      });
    }
  }

  void _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          name: name,
          email: email,
          phone: phone,
          location: location,
          imageUrl: imageUrl,
        ),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        name = result['name'] ?? name;
        email = result['email'] ?? email;
        phone = result['phone'] ?? phone;
        location = result['location'] ?? location;

        // Update image URL if it changed
        if (result['imageUrl'] != null && result['imageUrl']!.isNotEmpty) {
          imageUrl = result['imageUrl']!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashBoard(userEmail: email),
              ),
            );
          },
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : hasError
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _getUserEmailAndFetchProfile(),
                          child: const Text("Try Again"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueAccent,
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 100),
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(imageUrl),
                            backgroundColor: Colors.white,
                            onBackgroundImageError: (exception, stackTrace) {
                              print("Error loading image: $exception");
                              setState(() {
                                imageUrl = "https://i.pravatar.cc/300";
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            name,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 5),
                          const Text("Smart Aquarium Admin",
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 20),
                          Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.email,
                                        color: Colors.blueAccent),
                                    title: Text(email),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.phone,
                                        color: Colors.green),
                                    title: Text(phone),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.location_on,
                                        color: Colors.redAccent),
                                    title: Text(location),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _navigateToEdit,
                            icon: const Icon(Icons.edit),
                            label: const Text("Edit Profile"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
