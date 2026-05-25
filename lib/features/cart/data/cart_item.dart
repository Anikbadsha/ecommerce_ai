import '../../product/data/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  // FROM JSON
  factory CartItemModel.fromJson(
      Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(
        json['product'],
      ),
      quantity: json['quantity'],
    );
  }
}