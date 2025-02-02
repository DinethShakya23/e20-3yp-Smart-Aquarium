import 'package:flutter/material.dart';
import '../Widgets/dashboardbutton.dart';

class DashboardRow extends StatelessWidget {
  final IconData firstIcon;
  final String firstLabel;
  final Color firstColor;
  final IconData secondIcon;
  final String secondLabel;
  final Color secondColor;

  const DashboardRow(this.firstIcon, this.firstLabel, this.firstColor,
      this.secondIcon, this.secondLabel, this.secondColor,
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
              icon: firstIcon, label: firstLabel, color: firstColor),
          DashboardButton(
              icon: secondIcon, label: secondLabel, color: secondColor),
        ],
      ),
    );
  }
}
