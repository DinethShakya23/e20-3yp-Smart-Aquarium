import 'package:flutter/material.dart';

class NotificationButton extends StatelessWidget {
  final Function(BuildContext) onPressed;

  const NotificationButton(this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications_active, color: Colors.white),
      onPressed: () => onPressed(context),
    );
  }
}
