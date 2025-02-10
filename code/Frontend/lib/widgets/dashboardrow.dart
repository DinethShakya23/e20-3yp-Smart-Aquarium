import 'package:flutter/material.dart';
import 'dashboardbutton.dart';

class DashboardRow extends StatelessWidget {
  final IconData firstIcon;
  final String firstLabel;
  final Color firstColor;
  final IconData secondIcon;
  final String secondLabel;
  final Color secondColor;
  final Widget destination1;
  final Widget destination2;

  const DashboardRow(
      this.firstIcon,
      this.firstLabel,
      this.firstColor,
      this.destination1,
      this.secondIcon,
      this.secondLabel,
      this.secondColor,
      this.destination2,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DashboardButton(
            icon: firstIcon,
            label: firstLabel,
            color: firstColor,
            destinationScreen: destination1,
          ),
          DashboardButton(
            icon: secondIcon,
            label: secondLabel,
            color: secondColor,
            destinationScreen: destination2,
          ),
        ],
      ),
    );
  }
}
