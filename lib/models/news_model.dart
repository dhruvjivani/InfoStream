class News {
  final String title;
  final String description;

  News({required this.title, required this.description});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? 'No description',
    );
  }
}
