class CarouselItemModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? link;
  final int order;

  CarouselItemModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.link,
    required this.order,
  });

  factory CarouselItemModel.fromJson(Map<String, dynamic> json) {
    return CarouselItemModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      link: json['link'],
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'link': link,
      'order': order,
    };
  }
}
