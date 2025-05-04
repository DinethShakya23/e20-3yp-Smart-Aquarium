import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';

class DashboardPopupMenu extends StatelessWidget {
  final String userEmail;

  const DashboardPopupMenu({
    required this.userEmail,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'logout') {
          _showLogoutConfirmation(context);
        } else if (value == 'profile') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userEmail: userEmail),
            ),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
            value: 'profile',
            child: ListTile(
                leading: Icon(Icons.person, color: Colors.blueAccent),
                title: Text('Profile'))),
        const PopupMenuDivider(),
        const PopupMenuItem(
            value: 'help',
            child: ListTile(
                leading: Icon(Icons.help, color: Colors.green),
                title: Text('Help & Support'))),
        const PopupMenuDivider(),
        const PopupMenuItem(
            value: 'feedback',
            child: ListTile(
                leading: Icon(Icons.feedback, color: Colors.purple),
                title: Text('Send Feedback'))),
        const PopupMenuDivider(),
        const PopupMenuItem(
            value: 'logout',
            child: ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('Logout'))),
      ],
      icon: const Icon(Icons.menu, color: Colors.white),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () async {
                // Clear saved user email when logging out
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('userEmail');

                // Navigate to login screen and clear navigation stack
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false, // Remove all previous routes
                  );
                }
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
