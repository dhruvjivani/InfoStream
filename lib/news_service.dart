import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/news_model.dart';

enum NewsSource { headlines, apple, tesla, techcrunch }

class NewsService {
  final String apiKey = 'bf888bb9aa1c4d08af9692d2ca3db2e3';

  Future<List<News>> fetchNews(NewsSource source) async {
    late String url;

    switch (source) {
      case NewsSource.headlines:
        url = 'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey';
        break;
      case NewsSource.apple:
        url = 'https://newsapi.org/v2/everything?q=Apple&from=2025-07-22&sortBy=popularity&apiKey=$apiKey';
        break;
      case NewsSource.tesla:
        url = 'https://newsapi.org/v2/everything?q=Tesla&from=2025-07-22&sortBy=popularity&apiKey=$apiKey';
        break;
      case NewsSource.techcrunch:
        url = 'https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=$apiKey';
        break;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['articles'] as List)
          .map((item) => News.fromJson(item))
          .toList();
    } else {
      throw Exception("Failed to load news from $source");
    }
  }
}
