class ProductModel {
  final String title;
  final String price;
  final String description;
  final String image;

  ProductModel({
    required this.title,
    required this.price,
    required this.description,
    required this.image,
  });

  // CONVERT TO MAP
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'image': image,
    };
  }

  // CONVERT FROM MAP
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      title: json['title'],
      price: json['price'],
      description: json['description'],
      image: json['image'],
    );
  }
}