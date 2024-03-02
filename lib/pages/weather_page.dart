import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late String cityName = "Davao City";
  late String temperature = "";
  late String condition = "";

  Future<void> fetchWeatherData() async {
    const apiKey = '0af91b7826854c791de8fa120991d2e3';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        setState(() {
          temperature = "${decodedResponse['main']['temp']}°C";
          condition = decodedResponse['weather'][0]['main'];
        });
      } else {
        print(
            'Failed to load weather data. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching weather data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(condition),
      appBar: AppBar(
        backgroundColor: getAppBarColor(condition),
        title: const Text(
          "Weather Update",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getWeatherIcon(condition),
            const SizedBox(height: 20.0),
            Text(
              cityName,
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: getTextColor(condition),
              ),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Temperature:",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: getTextColor(condition),
                  ),
                ),
                const SizedBox(width: 10.0),
                Text(
                  temperature,
                  style: TextStyle(
                    fontSize: 24.0,
                    color: getTextColor(condition),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Condition:",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: getTextColor(condition),
                  ),
                ),
                const SizedBox(width: 10.0),
                Text(
                  condition,
                  style: TextStyle(
                    fontSize: 24.0,
                    color: getTextColor(condition),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color getBackgroundColor(String condition) {
    switch (condition) {
      case "Clear":
        return Colors.lightBlueAccent;
      case "Clouds":
        return Colors.blueGrey;
      case "Rain":
        return Colors.grey;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  Color getAppBarColor(String condition) {
    switch (condition) {
      case "Clear":
        return Colors.lightBlueAccent;
      case "Clouds":
        return Colors.blueGrey.shade800;
      case "Rain":
        return Colors.grey.shade900;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  Color getTextColor(String condition) {
    if (getAppBarColor(condition).computeLuminance() < 0.5) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  Widget getWeatherIcon(String condition) {
    switch (condition) {
      case "Clear":
        return const Icon(Icons.sunny, size: 100.0);
      case "Clouds":
        return const Icon(Icons.cloud, size: 100.0);
      case "Rain":
        return const Icon(Icons.water_drop_sharp, size: 100.0);
      default:
        return const Icon(Icons.cloud, size: 100.0);
    }
  }
}
