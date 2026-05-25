import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/cart_item.dart';
import '../../product/data/models/product_model.dart';

class CartController extends ChangeNotifier {

  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  CartController() {
    loadCart();
  }

  // ADD TO CART
  void addToCart(ProductModel product) {

    final index = _items.indexWhere(
      (item) => item.product.title == product.title,
    );

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(
        CartItemModel(product: product),
      );
    }

    saveCart();

    notifyListeners();
  }

  // REMOVE
  void removeFromCart(ProductModel product) {

    _items.removeWhere(
      (item) => item.product.title == product.title,
    );

    saveCart();

    notifyListeners();
  }

  // INCREASE
  void increaseQty(CartItemModel item) {

    item.quantity++;

    saveCart();

    notifyListeners();
  }

  // DECREASE
  void decreaseQty(CartItemModel item) {

    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }

    saveCart();

    notifyListeners();
  }

  // TOTAL
  double get totalPrice {

    double total = 0;

    for (var item in _items) {

      total += double.parse(
        item.product.price.replaceAll('\$', ''),
      ) * item.quantity;
    }

    return total;
  }

  // BADGE COUNT
  int get itemCount {

    int count = 0;

    for (var item in _items) {
      count += item.quantity;
    }

    return count;
  }

  // CLEAR
  void clearCart() {

    _items.clear();

    saveCart();

    notifyListeners();
  }

  // SAVE
  Future<void> saveCart() async {

    final prefs =
        await SharedPreferences.getInstance();

    final data = _items
        .map(
          (item) => jsonEncode(item.toJson()),
        )
        .toList();

    await prefs.setStringList(
      'cart',
      data,
    );
  }

  // LOAD
  Future<void> loadCart() async {

    final prefs =
        await SharedPreferences.getInstance();

    final data =
        prefs.getStringList('cart');

    if (data != null) {

      _items.clear();

      _items.addAll(
        data.map(
          (item) => CartItemModel.fromJson(
            jsonDecode(item),
          ),
        ),
      );

      notifyListeners();
    }
  }
}