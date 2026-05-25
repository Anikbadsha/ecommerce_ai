import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../product/data/models/product_model.dart';

class WishlistController extends ChangeNotifier {

  final List<ProductModel> _wishlist = [];

  List<ProductModel> get wishlist => _wishlist;

  WishlistController() {
    loadWishlist();
  }

  bool isExist(ProductModel product) {
    return _wishlist.any(
      (item) => item.title == product.title,
    );
  }

  void toggleWishlist(ProductModel product) {

    if (isExist(product)) {
      _wishlist.removeWhere(
        (item) => item.title == product.title,
      );
    } else {
      _wishlist.add(product);
    }

    saveWishlist();

    notifyListeners();
  }

  // SAVE DATA
  Future<void> saveWishlist() async {

    final prefs =
        await SharedPreferences.getInstance();

    final data = _wishlist
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    await prefs.setStringList(
      'wishlist',
      data,
    );
  }

  // LOAD DATA
  Future<void> loadWishlist() async {

    final prefs =
        await SharedPreferences.getInstance();

    final data =
        prefs.getStringList('wishlist');

    if (data != null) {

      _wishlist.clear();

      _wishlist.addAll(
        data.map(
          (item) => ProductModel.fromJson(
            jsonDecode(item),
          ),
        ),
      );

      notifyListeners();
    }
  }
}