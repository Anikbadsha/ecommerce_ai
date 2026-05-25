import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/order_model.dart';
import '../../cart/data/cart_item.dart';

class OrderController extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<OrderModel> _orders = [];
  bool _loading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get loading => _loading;
  String? get error => _error;

  String? get _uid => _auth.currentUser?.uid;

  Future<void> fetchOrders() async {
    if (_uid == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // No orderBy to avoid requiring a composite index
      final snap = await _db
          .collection('orders')
          .where('uid', isEqualTo: _uid)
          .get();
      _orders = snap.docs
          .map((d) => OrderModel.fromJson(d.data()))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // sort client-side
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> placeOrder({
    required List<CartItemModel> items,
    required double total,
    required String address,
    required String paymentMethod,
  }) async {
    if (_uid == null) return 'Not logged in';
    try {
      final ref = _db.collection('orders').doc();
      final order = OrderModel(
        id: ref.id,
        status: 'processing',
        total: total,
        createdAt: DateTime.now(),
        address: address,
        paymentMethod: paymentMethod,
        items: items
            .map((i) => OrderItem(
                  title: i.product.title,
                  price: i.product.price,
                  image: i.product.image,
                  quantity: i.quantity,
                ))
            .toList(),
      );
      await ref.set({...order.toJson(), 'uid': _uid});
      _orders.insert(0, order);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
