import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String status; // processing | in_transit | delivered | cancelled
  final double total;
  final DateTime createdAt;
  final List<OrderItem> items;
  final String address;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
    required this.address,
    required this.paymentMethod,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id: j['id'] ?? '',
        status: j['status'] ?? 'processing',
        total: (j['total'] ?? 0).toDouble(),
        // Handle both Firestore Timestamp and ISO string (BUG-001 fix)
        createdAt: _parseDate(j['createdAt']),
        items: (j['items'] as List? ?? [])
            .map((e) => OrderItem.fromJson(e))
            .toList(),
        address: j['address'] ?? '',
        paymentMethod: j['paymentMethod'] ?? '',
      );

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'total': total,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'address': address,
        'paymentMethod': paymentMethod,
      };
}

class OrderItem {
  final String title;
  final String price;
  final String image;
  final int quantity;

  OrderItem({
    required this.title,
    required this.price,
    required this.image,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        title: j['title'] ?? '',
        price: j['price'] ?? '',
        image: j['image'] ?? '',
        quantity: j['quantity'] ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'price': price,
        'image': image,
        'quantity': quantity,
      };
}
