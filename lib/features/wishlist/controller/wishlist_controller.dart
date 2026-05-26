import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../product/data/models/product_model.dart';

class WishlistController extends ChangeNotifier {

  final List<ProductModel> _wishlist = [];

  List<ProductModel> get wishlist => _wishlist;

  WishlistController() {
    // Defer to avoid notifyListeners during widget tree construction
    WidgetsBinding.instance.addPostFrameCallback((_) => loadWishlist());
  }

  // Prefer id-based match; fall back to title for legacy wishlist data
  bool _sameProduct(ProductModel a, ProductModel b) {
    if (a.id.isNotEmpty && b.id.isNotEmpty) return a.id == b.id;
    return a.title == b.title;
  }

  bool isExist(ProductModel product) {
    return _wishlist.any((item) => _sameProduct(item, product));
  }

  void toggleWishlist(ProductModel product) {
    if (isExist(product)) {
      _wishlist.removeWhere((item) => _sameProduct(item, product));
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