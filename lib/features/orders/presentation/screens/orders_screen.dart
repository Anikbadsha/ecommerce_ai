
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_ai/core/theme/app_theme.dart';
import 'package:ecommerce_ai/features/cart/controller/cart_controller.dart';
import 'package:ecommerce_ai/features/orders/controller/order_controller.dart';
import 'package:ecommerce_ai/features/orders/data/order_model.dart';
import 'package:ecommerce_ai/features/product/data/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<OrderController>().fetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Orders',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
      ),
      body: Consumer<OrderController>(
        builder: (_, ctrl, child) {
          if (ctrl.loading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.blue));
          }
          if (ctrl.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.receipt_long_rounded,
                        size: 44, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Text('No orders yet',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('Your placed orders will appear here',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.blue,
            backgroundColor: AppColors.card,
            onRefresh: () => context.read<OrderController>().fetchOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: ctrl.orders.length,
              itemBuilder: (_, i) => _OrderCard(order: ctrl.orders[i]),
            ),
          );
        },
      ),
    );
  }
}

void _showTracking(BuildContext context, OrderModel order) {
  const steps = ['processing', 'confirmed', 'in_transit', 'delivered'];
  const stepLabels = ['Order Placed', 'Confirmed', 'In Transit', 'Delivered'];
  const stepIcons = [
    Icons.receipt_long_rounded,
    Icons.check_circle_outline_rounded,
    Icons.local_shipping_rounded,
    Icons.home_rounded,
  ];

  // Normalize any Firestore value to snake_case for lookup:
  // "In Transit" → "in_transit", "Delivered" → "delivered", etc.
  String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll(' ', '_');

  // Live stream of just the status field for this order
  final statusStream = FirebaseFirestore.instance
      .collection('orders')
      .doc(order.id)
      .snapshots()
      .map((snap) => snap.data()?['status'] as String? ?? order.status);

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.bgSecondary,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => StreamBuilder<String>(
      stream: statusStream,
      initialData: order.status,
      builder: (_, snap) {
        final currentIdx =
            steps.indexOf(_normalize(snap.data ?? order.status))
                .clamp(0, steps.length - 1);

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order Tracking',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Order #${order.id.length > 12 ? order.id.substring(0, 12) : order.id}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 24),
              ...List.generate(steps.length, (i) {
                final done = i <= currentIdx;
                final active = i == currentIdx;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          gradient: done ? AppColors.ctaGradient : null,
                          color: done ? null : AppColors.card,
                          shape: BoxShape.circle,
                          border: done
                              ? null
                              : Border.all(color: AppColors.border),
                        ),
                        child: Icon(stepIcons[i],
                            size: 16,
                            color: done
                                ? Colors.white
                                : AppColors.textSecondary),
                      ),
                      if (i < steps.length - 1)
                        Container(
                          width: 2, height: 32,
                          color: i < currentIdx
                              ? AppColors.blue
                              : AppColors.border,
                        ),
                    ]),
                    const SizedBox(width: 14),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(stepLabels[i],
                          style: TextStyle(
                            color: active
                                ? AppColors.textPrimary
                                : done
                                    ? AppColors.textSecondary
                                    : AppColors.border,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 14,
                          )),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    ),
  );
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  static const _statusColors = {
    'processing': AppColors.blue,
    'in_transit': AppColors.warning,
    'delivered': AppColors.success,
    'cancelled': AppColors.error,
  };

  static const _statusLabels = {
    'processing': 'Processing',
    'in_transit': 'In Transit',
    'delivered': 'Delivered',
    'cancelled': 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    final color = _statusColors[order.status] ?? AppColors.blue;
    final label = _statusLabels[order.status] ?? order.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(order.id.length > 16 ? '#${order.id.substring(0, 16)}' : '#${order.id}',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 10),
        Text('${order.items.length} item${order.items.length > 1 ? 's' : ''}  •  ${order.paymentMethod}',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(Icons.calendar_today_rounded,
                size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
                '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ]),
          ShaderMask(
            shaderCallback: (b) => AppColors.ctaGradient.createShader(b),
            child: Text('\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 36),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showTracking(context, order),
              child: const Text('Track',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontSize: 12)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 36),
                side: const BorderSide(color: AppColors.blue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final cart = context.read<CartController>();
                for (final item in order.items) {
                  cart.addToCart(ProductModel(
                    title: item.title,
                    price: item.price,
                    image: item.image,
                    description: '',
                    category: '',
                  ));
                }
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      '${order.items.length} item${order.items.length > 1 ? 's' : ''} added to cart'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ));
              },
              child: const Text('Reorder',
                  style: TextStyle(color: AppColors.blue, fontSize: 12)),
            ),
          ),
        ]),
      ]),
    );
  }
}
