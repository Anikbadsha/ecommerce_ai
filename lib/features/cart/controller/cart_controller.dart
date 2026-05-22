import 'package:ecommerce_ai/features/cart/data/cart_item.dart';
import 'package:ecommerce_ai/features/product/data/models/product_model.dart';
import 'package:flutter/material.dart';

class CartController extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  void addToCart(ProductModel product) {
  final index = _items.indexWhere(
    (item) => item.product.title == product.title,
  );

  if (index >= 0) {
    _items[index].quantity++;
  } else {
    _items.add(CartItemModel(product: product));
  }

  notifyListeners();
}

  void removeFromCart(ProductModel product) {
    _items.removeWhere(
      (item) => item.product.title == product.title,
    );

    notifyListeners();
  }

  void increaseQty(CartItemModel item) {
  item.quantity++;
  notifyListeners();
}

void decreaseQty(CartItemModel item) {
  if (item.quantity > 1) {
    item.quantity--;
  } else {
    _items.remove(item);
  }
  notifyListeners();
}


  double get totalPrice {
    double total = 0;

    for (var item in _items) {
      total += double.parse(
        item.product.price.replaceAll('\$', ''),
      ) * item.quantity;
    }

    return total;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}