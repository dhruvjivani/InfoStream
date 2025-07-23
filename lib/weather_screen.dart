import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/weather_model.dart';
import 'weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final List<String> defaultCities = ['Toronto', 'Vancouver', 'Waterloo', 'Kitchener'];
  final TextEditingController cityController = TextEditingController();
  final List<Weather> weatherData = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadStoredCities();
  }

  // Load cities from SharedPreferences or use defaults
  Future<void> _loadStoredCities() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCities = prefs.getStringList('cities') ?? defaultCities;
    await _loadCities(storedCities);
  }

  // Save updated list to SharedPreferences
  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    final cities = weatherData.map((w) => w.city).toList();
    await prefs.setStringList('cities', cities);
  }

  // Load weather for all given cities
  Future<void> _loadCities(List<String> cities) async {
    setState(() {
      isLoading = true;
      error = null;
      weatherData.clear();
    });

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      setState(() {
        error = "No internet connection";
        isLoading = false;
      });
      return;
    }

    for (String city in cities) {
      try {
        final weather = await WeatherService().fetchWeather(city);
        if (weather != null) weatherData.add(weather);
      } catch (_) {
        // Skip silently if fetch fails for a city
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  // Add a new city from user input
  Future<void> _addCity() async {
    final city = cityController.text.trim();
    if (city.isEmpty) {
      _showError("Please enter a city name.");
      return;
    }

    try {
      final weather = await WeatherService().fetchWeather(city);
      if (weather != null) {
        setState(() {
          weatherData.add(weather);
          cityController.clear();
        });
        await _saveCities();
      }
    } catch (_) {
      _showError("City not found or API error.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather Info")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      hintText: "Add city name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addCity, child: const Text("Add")),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: weatherData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (_, i) {
                final weather = weatherData[i];
                return Card(
                  color: Colors.indigo.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(weather.city, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("${weather.temperature}°C"),
                        Text(weather.description),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
