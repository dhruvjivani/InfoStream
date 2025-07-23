import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'weather_screen.dart';
import 'news_screen.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: const InfoStreamApp(),
  ));
}

class InfoStreamApp extends StatelessWidget {
  const InfoStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'InfoStream',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(primarySwatch: Colors.indigo, brightness: Brightness.light),
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('InfoStream'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen())),
              icon: const Icon(Icons.cloud),
              label: const Text('Weather'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsScreen())),
              icon: const Icon(Icons.article),
              label: const Text('News'),
            ),
          ],
        ),
      ),
    );
  }
}
