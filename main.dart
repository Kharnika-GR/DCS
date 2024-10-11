import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Weather model
class Weather {
  final double temperature;
  final String condition;
  final double windSpeed;
  final double precipitationProbability;

  Weather({
    required this.temperature,
    required this.condition,
    required this.windSpeed,
    required this.precipitationProbability,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: json['current_weather']['temperature'],
      condition: json['current_weather']['weathercode'].toString(),
      windSpeed: json['current_weather']['windspeed'],
      precipitationProbability: json['current_weather']['precipitation_probability'],
    );
  }
}

// Weather service to fetch data from Open Meteo API
class WeatherService {
  Future<Weather> fetchWeather(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/weather?latitude=$latitude&longitude=$longitude&current_weather=true'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

// Main function and app widget
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WeatherScreen(),
    );
  }
}

// Weather screen to display the weather information
class WeatherScreen extends StatelessWidget {
  final double latitude = 37.7749; // Example latitude for San Francisco
  final double longitude = -122.4194; // Example longitude for San Francisco

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather App')),
      body: Center(
        child: FutureBuilder<Weather>(
          future: WeatherService().fetchWeather(latitude, longitude),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final weather = snapshot.data;
              return weather != null
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Temperature: ${weather.temperature}°C',
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            'Condition: ${weather.condition}',
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            'Wind Speed: ${weather.windSpeed} km/h',
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            'Precipitation Probability: ${weather.precipitationProbability}%',
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    )
                  : Text('No weather data available');
            }
          },
        ),
      ),
    );
  }
}
