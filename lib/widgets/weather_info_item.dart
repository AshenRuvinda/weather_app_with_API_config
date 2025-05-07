import 'package:flutter/material.dart';

class WeatherInfoItem extends StatelessWidget {
  final String value;
  final IconData icon;
  final String label;
  final Color textColor;
  final Color secondaryTextColor;

  const WeatherInfoItem({
    required this.value,
    required this.icon,
    required this.label,
    required this.textColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: textColor, size: 30),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(color: secondaryTextColor, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(color: secondaryTextColor, fontSize: 16),
        ),
      ],
    );
  }
}