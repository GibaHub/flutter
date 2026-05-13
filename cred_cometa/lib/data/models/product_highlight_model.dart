class ProductHighlightModel {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final double? oldPrice;
  final String type; // NEW, OFF_30, BEST_SELLER
  final String? link;
  final int order;

  ProductHighlightModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.oldPrice,
    required this.type,
    this.link,
    required this.order,
  });

  factory ProductHighlightModel.fromJson(Map<String, dynamic> json) {
    return ProductHighlightModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      oldPrice: json['oldPrice'] != null ? double.tryParse(json['oldPrice'].toString()) : null,
      type: json['type'] ?? 'NEW',
      link: json['link'],
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'oldPrice': oldPrice,
      'type': type,
      'link': link,
      'order': order,
    };
  }
}
