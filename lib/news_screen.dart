import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'models/news_model.dart';
import 'news_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<News> newsList = [];
  List<News> filteredList = [];
  bool isLoading = true;
  String? error;
  NewsSource selectedSource = NewsSource.apple;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      setState(() {
        error = "No internet connection.";
        isLoading = false;
      });
      return;
    }

    try {
      final data = await NewsService().fetchNews(selectedSource);
      if (data.isEmpty) {
        setState(() {
          error = "No news articles found.";
          isLoading = false;
        });
      } else {
        setState(() {
          newsList = data;
          filteredList = data;
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        error = "Failed to load news.";
        isLoading = false;
      });
    }
  }

  void _filterNews(String keyword) {
    final filtered = newsList
        .where((n) => n.title.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
    setState(() {
      filteredList = filtered;
    });
  }

  void _changeSource(NewsSource? source) {
    if (source != null) {
      setState(() => selectedSource = source);
      _loadNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("News Explorer")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: DropdownButtonFormField<NewsSource>(
              value: selectedSource,
              onChanged: _changeSource,
              decoration: const InputDecoration(
                labelText: "Select News Source",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: NewsSource.headlines,
                  child: Text("Top Headlines (US)"),
                ),
                DropdownMenuItem(
                  value: NewsSource.apple,
                  child: Text("Apple News"),
                ),
                DropdownMenuItem(
                  value: NewsSource.tesla,
                  child: Text("Tesla News"),
                ),
                DropdownMenuItem(
                  value: NewsSource.techcrunch,
                  child: Text("TechCrunch"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _filterNews,
              decoration: const InputDecoration(
                hintText: "Search in results...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("No matching news found."))
                : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: filteredList.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final news = filteredList[i];
                return ListTile(
                  title: Text(news.title),
                  subtitle: Text(news.description),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
