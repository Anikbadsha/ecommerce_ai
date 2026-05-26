import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CouponController extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  String _code = '';
  double _discount = 0.0;
  String? _error;
  bool _applied = false;
  bool _loading = false;

  String get code => _code;
  double get discount => _discount;
  String? get error => _error;
  bool get applied => _applied;
  bool get loading => _loading;

  Future<void> apply(String code) async {
    _code = code.trim().toUpperCase();
    if (_code.isEmpty) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await _db.collection('coupons').doc(_code).get();
      if (doc.exists && (doc.data()?['active'] == true)) {
        _discount = (doc.data()?['discount'] ?? 0).toDouble();
        _applied = true;
        _error = null;
      } else {
        _discount = 0;
        _applied = false;
        _error = 'Invalid or expired coupon';
      }
    } catch (_) {
      // Firestore unavailable — fall back to hardcoded codes
      const fallback = {'SAVE10': 0.10, 'SAVE20': 0.20, 'WELCOME': 0.15};
      if (fallback.containsKey(_code)) {
        _discount = fallback[_code]!;
        _applied = true;
        _error = null;
      } else {
        _discount = 0;
        _applied = false;
        _error = 'Invalid coupon code';
      }
    }

    _loading = false;
    notifyListeners();
  }

  void clear() {
    _code = '';
    _discount = 0;
    _error = null;
    _applied = false;
    _loading = false;
    notifyListeners();
  }

  double discountedTotal(double total) =>
      _applied ? total * (1 - _discount) : total;
}
