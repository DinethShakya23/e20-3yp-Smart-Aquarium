import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;

  const NotificationItem(this.icon, this.title, this.message, this.time,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(message, style: const TextStyle(color: Colors.white70)),
      trailing: Text(time,
          style: const TextStyle(color: Colors.white54, fontSize: 12)),
    );
  }
}
