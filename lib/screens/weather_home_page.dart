import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/weather_service.dart';
import '../models/weather_data.dart';
import '../widgets/weather_info_item.dart';
import '../widgets/forecast_card.dart';
import '../widgets/theme_switcher.dart';
import 'notifications_page.dart';

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  late WeatherService _weatherService;
  WeatherData? _weatherData;
  bool isLoading = true;
  String errorMessage = '';
  bool isDarkMode = true;

  // Theme colors
  late Color backgroundColor;
  late Color cardColor;
  late Color textColor;
  late Color secondaryTextColor;

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherService();
    _updateThemeColors();
    _loadWeatherData();
  }

  void _updateThemeColors() {
    setState(() {
      backgroundColor = isDarkMode ? Color(0xFF1E1E2C) : Colors.white;
      cardColor = isDarkMode ? Color(0xFF2C2C3A) : Colors.grey[200]!;
      textColor = isDarkMode ? Colors.white : Colors.black;
      secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    });
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      _updateThemeColors();
    });
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final weatherData = await _weatherService.fetchWeatherData();
      setState(() {
        _weatherData = weatherData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void retryFetchWeatherData() {
    _loadWeatherData();
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();

    if (condition.contains('thunderstorm') || condition.contains('11d')) {
      return Icons.flash_on;
    } else if (condition.contains('drizzle') || condition.contains('09d')) {
      return Icons.grain;
    } else if (condition.contains('rain') || condition.contains('10d')) {
      return Icons.water_drop;
    } else if (condition.contains('snow') || condition.contains('13d')) {
      return Icons.ac_unit;
    } else if (condition.contains('mist') || condition.contains('fog') ||
        condition.contains('haze') || condition.contains('50d')) {
      return Icons.cloud;
    } else if (condition.contains('clear') || condition.contains('01d')) {
      return Icons.wb_sunny;
    } else if (condition.contains('clouds') || condition.contains('02d') ||
        condition.contains('03d') || condition.contains('04d')) {
      return Icons.cloud;
    }

    return Icons.cloud;
  }

  // Add this method to handle navigation
  void _navigateToPage(int index) {
    if (index == 0) {
      // Already on home page
      return;
    } else if (index == 2) { // Notifications tab
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationsPage(isDarkMode: isDarkMode),
        ),
      );
    } else {
      // Show a snackbar for unimplemented features
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This feature is coming soon!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: null,
      body: SafeArea(
        child: isLoading
            ? _buildLoadingView()
            : errorMessage.isNotEmpty
            ? _buildErrorView()
            : _buildWeatherContent(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: textColor),
          SizedBox(height: 20),
          Text('Loading weather data...', style: TextStyle(color: textColor)),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 20),
            Text(
              errorMessage,
              style: TextStyle(color: textColor, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: retryFetchWeatherData,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text('Retry', style: TextStyle(fontSize: 16)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_weatherData == null) return Container();

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row with menu and theme switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.menu, color: textColor, size: 30),
                // Theme switcher
                ThemeSwitcher(
                  isDarkMode: isDarkMode,
                  onToggle: toggleTheme,
                  cardColor: cardColor,
                ),
              ],
            ),
          ),
          Text(
            _weatherData!.location,
            style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Icon(
              _getWeatherIcon(_weatherData!.description),
              color: Colors.blueAccent,
              size: 100
          ),
          const SizedBox(height: 20),
          Text(
            _weatherData!.temperature,
            style: TextStyle(color: textColor, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _weatherData!.description,
            style: TextStyle(color: secondaryTextColor, fontSize: 18),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              WeatherInfoItem(
                value: _weatherData!.windSpeed,
                icon: Icons.air,
                label: 'Wind',
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              WeatherInfoItem(
                value: _weatherData!.humidity,
                icon: Icons.water_drop,
                label: 'Humidity',
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              WeatherInfoItem(
                value: _weatherData!.uvIndex,
                icon: Icons.wb_sunny,
                label: 'UV Index',
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hourly Forecast',
                style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 100,
            child: _weatherData!.hourlyForecast.isEmpty
                ? Center(child: Text('No forecast available',
                style: TextStyle(color: secondaryTextColor)))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _weatherData!.hourlyForecast.length,
              itemBuilder: (context, index) {
                final forecast = _weatherData!.hourlyForecast[index];
                return ForecastCard(
                  time: forecast['time']!,
                  temp: forecast['temp']!,
                  icon: _getWeatherIcon(forecast['icon'] ?? 'cloud'),
                  cardColor: cardColor,
                  textColor: textColor,
                );
              },
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: textColor,
          unselectedItemColor: secondaryTextColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          ],
          currentIndex: 0,
          onTap: _navigateToPage,
        ),
      ),
    );
  }
}