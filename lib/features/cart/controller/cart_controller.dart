import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/cart_item.dart';
import '../../product/data/models/product_model.dart';

class CartController extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  final _db = FirebaseFirestore.instance;
  Timer? _debounce;

  List<CartItemModel> get items => List.unmodifiable(_items);

  CartController() {
    // Defer load until after first frame so notifyListeners is safe
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocal());
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // Prefer id-based match; fall back to title for legacy cart data (no id)
  bool _sameProduct(ProductModel a, ProductModel b) {
    if (a.id.isNotEmpty && b.id.isNotEmpty) return a.id == b.id;
    return a.title == b.title;
  }

  // ── Computed ──────────────────────────────────────────────
  double get totalPrice => _items.fold(0, (acc, item) {
        final raw = item.product.price.replaceAll(RegExp(r'[^\d.]'), '');
        return acc + (double.tryParse(raw) ?? 0) * item.quantity;
      });

  int get itemCount => _items.fold(0, (acc, item) => acc + item.quantity);

  // ── Mutations ─────────────────────────────────────────────
  void addToCart(ProductModel product) {
    // Use id if available, fall back to title for legacy data
    final idx = _items.indexWhere((i) => _sameProduct(i.product, product));
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItemModel(product: product));
    }
    _persist();
    notifyListeners();
  }

  void removeFromCart(ProductModel product) {
    _items.removeWhere((i) => _sameProduct(i.product, product));
    _persist();
    notifyListeners();
  }

  void increaseQty(CartItemModel item) {
    item.quantity++;
    _persist();
    notifyListeners();
  }

  void decreaseQty(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    _persist();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _persist();
    notifyListeners();
  }

  // ── Persistence ───────────────────────────────────────────
  // Debounced: batches rapid mutations into one write per 800ms
  void _persist() {
    _saveLocal();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _saveFirestore);
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'cart',
      _items.map((i) => jsonEncode(i.toJson())).toList(),
    );
  }

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('cart');
    if (data != null && data.isNotEmpty) {
      _items.clear();
      _items.addAll(data.map((s) => CartItemModel.fromJson(jsonDecode(s))));
      notifyListeners();
    }
    // After local load, sync from Firestore if logged in
    if (_uid != null) await _loadFirestore();
  }

  Future<void> _saveFirestore() async {
    if (_uid == null) return;
    try {
      await _db.collection('carts').doc(_uid).set({
        'items': _items
            .map((i) => {
                  'id': i.product.id,
                  'title': i.product.title,
                  'price': i.product.price,
                  'description': i.product.description,
                  'image': i.product.image,
                  'category': i.product.category,
                  'quantity': i.quantity,
                })
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {} // non-critical — local cache is source of truth
  }

  Future<void> _loadFirestore() async {
    if (_uid == null) return;
    try {
      final doc = await _db.collection('carts').doc(_uid).get();
      if (!doc.exists) return;
      final raw = doc.data()?['items'] as List?;
      if (raw == null || raw.isEmpty) return;
      _items.clear();
      _items.addAll(raw.map((e) => CartItemModel(
            product: ProductModel(
              id: e['id'] ?? '',
              title: e['title'] ?? '',
              price: e['price'] ?? '',
              description: e['description'] ?? '',
              image: e['image'] ?? '',
              category: e['category'] ?? '',
            ),
            quantity: e['quantity'] ?? 1,
          )));
      notifyListeners();
      await _saveLocal(); // keep local in sync
    } catch (_) {}
  }

  // Called after login to sync cloud cart
  Future<void> syncAfterLogin() => _loadFirestore();

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
