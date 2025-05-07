class WeatherData {
  final String location;
  final String temperature;
  final String description;
  final String windSpeed;
  final String humidity;
  final String uvIndex;
  final List<Map<String, String>> hourlyForecast;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.description,
    required this.windSpeed,
    required this.humidity,
    required this.uvIndex,
    required this.hourlyForecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> forecasts = [];

    try {
      if (json.containsKey('hourly') && json['hourly'] is List) {
        final hourlyList = json['hourly'] as List;
        for (var i = 0; i < 4 && i < hourlyList.length; i++) {
          final hour = hourlyList[i] as Map<String, dynamic>;
          if (hour.containsKey('dt') && hour.containsKey('temp') && hour.containsKey('weather')) {
            forecasts.add({
              'time': '${DateTime.fromMillisecondsSinceEpoch((hour['dt'] as int) * 1000).hour}:00',
              'temp': '${(hour['temp'] as num).toStringAsFixed(1)}°C',
              'icon': (hour['weather'][0]['icon'] as String?) ?? 'cloud',
            });
          }
        }
      }
    } catch (e) {
      print('Error processing hourly forecast: $e');
      // Continue with empty forecasts
    }

    try {
      return WeatherData(
        location: json['name'] ?? 'Your Location',
        temperature: '${(json['main']['temp'] as num).toStringAsFixed(1)}°C',
        description: json['weather'][0]['description'] as String? ?? 'Weather condition',
        windSpeed: '${(json['wind']['speed'] as num? ?? 0)} km/hr',
        humidity: '${(json['main']['humidity'] as num? ?? 0)}%',
        uvIndex: 'N/A',
        hourlyForecast: forecasts,
      );
    } catch (e) {
      print('Error creating WeatherData: $e');
      return WeatherData(
        location: 'Your Location',
        temperature: 'N/A',
        description: 'Unable to fetch weather',
        windSpeed: 'N/A',
        humidity: 'N/A',
        uvIndex: 'N/A',
        hourlyForecast: [],
      );
    }
  }
}