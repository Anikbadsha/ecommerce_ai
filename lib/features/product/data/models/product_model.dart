class ProductModel {
  final String title;
  final String price;
  final String description;
  final String image;
  final String category;
  final double rating;
  final int reviewCount;
  final int discount; // percentage, 0 = no discount

  ProductModel({
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    required this.category,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.discount = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 4.5).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      discount: json['discount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'price': price,
        'description': description,
        'image': image,
        'category': category,
        'rating': rating,
        'reviewCount': reviewCount,
        'discount': discount,
      };
}