import 'package:flutter/material.dart';

class CouponController extends ChangeNotifier {
  static const _coupons = {
    'SAVE10': 0.10,
    'SAVE20': 0.20,
    'WELCOME': 0.15,
  };

  String _code = '';
  double _discount = 0.0;
  String? _error;
  bool _applied = false;

  String get code => _code;
  double get discount => _discount; // fraction e.g. 0.10
  String? get error => _error;
  bool get applied => _applied;

  void apply(String code) {
    _code = code.trim().toUpperCase();
    if (_coupons.containsKey(_code)) {
      _discount = _coupons[_code]!;
      _error = null;
      _applied = true;
    } else {
      _discount = 0;
      _error = 'Invalid coupon code';
      _applied = false;
    }
    notifyListeners();
  }

  void clear() {
    _code = '';
    _discount = 0;
    _error = null;
    _applied = false;
    notifyListeners();
  }

  double discountedTotal(double total) =>
      _applied ? total * (1 - _discount) : total;
}
