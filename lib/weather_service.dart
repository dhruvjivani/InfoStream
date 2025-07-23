import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/weather_model.dart';

class WeatherService {
  final String apiKey = 'd8689c616a725f7030af006193e3e201'; // OpenWeatherMap key

  Future<Weather?> fetchWeather(String city) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load weather");
    }
  }
}
