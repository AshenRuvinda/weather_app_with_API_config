import 'package:flutter/material.dart';

class ThemeSwitcher extends StatelessWidget {
  final bool isDarkMode;
  final Function onToggle;
  final Color cardColor;

  const ThemeSwitcher({
    required this.isDarkMode,
    required this.onToggle,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(),
      child: Container(
        width: 96,
        height: 40,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              left: isDarkMode ? 56 : 4,
              top: 4,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black87 : Colors.blue[400],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}