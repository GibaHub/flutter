class NewsModel {
  final String id;
  final String title;
  final String? subtitle;
  final String content;
  final String imageUrl;
  final DateTime publishedAt;

  NewsModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.content,
    required this.imageUrl,
    required this.publishedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }
}
