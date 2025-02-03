import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

class PopupMenu extends StatelessWidget {
  final BuildContext context;

  const PopupMenu(this.context, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout') {
          _showLogoutConfirmation(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
            value: 'profile',
            child: ListTile(
                leading: Icon(Icons.person, color: Colors.blueAccent),
                title: Text('Profile'))),
        const PopupMenuItem(
            value: 'settings',
            child: ListTile(
                leading: Icon(Icons.settings, color: Colors.orangeAccent),
                title: Text('Settings'))),
        const PopupMenuDivider(),
        const PopupMenuItem(
            value: 'help',
            child: ListTile(
                leading: Icon(Icons.help, color: Colors.green),
                title: Text('Help & Support'))),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
