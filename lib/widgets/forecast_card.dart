import 'package:flutter/material.dart';

class ForecastCard extends StatelessWidget {
  final String time;
  final String temp;
  final IconData icon;
  final Color cardColor;
  final Color textColor;

  const ForecastCard({
    required this.time,
    required this.temp,
    required this.icon,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      margin: const EdgeInsets.only(left: 15),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(height: 5),
          Text(
            time,
            style: TextStyle(color: textColor, fontSize: 14),
          ),
          const SizedBox(height: 3),
          Text(
            temp,
            style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}