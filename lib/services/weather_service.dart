import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_data.dart';

class WeatherService {
  final String apiKey = 'eaab9d8ffdc36d7f3c867e76e0687886';
  final Duration shortTimeout = const Duration(seconds: 5);
  final Duration normalTimeout = const Duration(seconds: 8);

  Future<WeatherData> fetchWeatherData() async {
    try {
      await _checkLocationPermission();
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );

      final lat = position.latitude;
      final lon = position.longitude;

      WeatherData weatherData = await _fetchDirectWeatherData(lat, lon);

      // Try to fetch hourly forecast data
      try {
        final hourlyData = await _fetchHourlyForecast(lat, lon);
        if (hourlyData.isNotEmpty) {
          weatherData = WeatherData(
            location: weatherData.location,
            temperature: weatherData.temperature,
            description: weatherData.description,
            windSpeed: weatherData.windSpeed,
            humidity: weatherData.humidity,
            uvIndex: weatherData.uvIndex,
            hourlyForecast: hourlyData,
          );
        }
      } catch (e) {
        print('Hourly forecast fetch failed: ${e.toString()}');
        // Continue with already fetched weather data
      }

      return weatherData;
    } catch (e) {
      rethrow; // Properly propagate the exception
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them in settings.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable in settings.');
    }
  }

  Future<WeatherData> _fetchDirectWeatherData(double lat, double lon) async {
    try {
      final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey');
      final client = http.Client();
      final response = await client.get(url).timeout(normalTimeout);
      client.close();

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        WeatherData weatherData = WeatherData.fromJson(data);

        if (weatherData.hourlyForecast.isEmpty) {
          weatherData = _addBasicForecast(weatherData, data);
        }

        return weatherData;
      } else {
        throw Exception('Weather service unavailable (${response.statusCode}). Please try again later.');
      }
    } on TimeoutException {
      throw Exception('Weather service not responding. Please try again later.');
    } catch (e) {
      throw Exception('Unable to get weather information. Please try again.');
    }
  }

  WeatherData _addBasicForecast(WeatherData weatherData, Map<String, dynamic> data) {
    final now = DateTime.now();
    final currentTemp = data['main']['temp'] as double;
    final icon = data['weather'][0]['icon'] as String;

    List<Map<String, String>> hourlyForecast = List.generate(4, (index) {
      final hour = now.add(Duration(hours: index + 1));
      final tempVariation = (index * 0.5) * (index % 2 == 0 ? 1 : -1);
      final forecastTemp = currentTemp + tempVariation;

      return {
        'time': '${hour.hour}:00',
        'temp': '${forecastTemp.toStringAsFixed(1)}°C',
        'icon': icon,
      };
    });

    return WeatherData(
      location: weatherData.location,
      temperature: weatherData.temperature,
      description: weatherData.description,
      windSpeed: weatherData.windSpeed,
      humidity: weatherData.humidity,
      uvIndex: weatherData.uvIndex,
      hourlyForecast: hourlyForecast,
    );
  }

  Future<List<Map<String, String>>> _fetchHourlyForecast(double lat, double lon) async {
    try {
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,daily,alerts&units=metric&appid=$apiKey');
      final client = http.Client();
      final response = await client.get(url).timeout(shortTimeout);
      client.close();

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data.containsKey('hourly') && data['hourly'] is List) {
          List<Map<String, String>> hourlyForecast = [];

          final hourlyList = data['hourly'] as List;
          for (var i = 0; i < 4 && i < hourlyList.length; i++) {
            final hour = hourlyList[i] as Map<String, dynamic>;
            if (hour.containsKey('dt') && hour.containsKey('temp') && hour.containsKey('weather')) {
              hourlyForecast.add({
                'time': '${DateTime.fromMillisecondsSinceEpoch((hour['dt'] as int) * 1000).hour}:00',
                'temp': '${(hour['temp'] as num).toStringAsFixed(1)}°C',
                'icon': (hour['weather'][0]['icon'] as String? ?? 'cloud'),
              });
            }
          }
          return hourlyForecast;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching hourly forecast: ${e.toString()}');
      return [];
    }
  }
}