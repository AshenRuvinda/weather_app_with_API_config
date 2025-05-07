import 'package:flutter/material.dart';
import '../screens/weather_home_page.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        platform: TargetPlatform.android,
      ),
      home: WeatherHomePage(),
    );
  }
}