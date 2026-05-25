import 'package:ecommerce_ai/core/theme/app_theme.dart';
import 'package:ecommerce_ai/core/widgets/gradient_button.dart';
import 'package:ecommerce_ai/features/cart/controller/cart_controller.dart';
import 'package:ecommerce_ai/features/checkout/controller/coupon_controller.dart';
import 'package:ecommerce_ai/features/orders/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _payIdx = 0;
  bool _placing = false;
  final _couponCtrl = TextEditingController();

  static const _methods = [
    (Icons.credit_card_rounded, 'Credit Card'),
    (Icons.account_balance_wallet_rounded, 'PayPal'),
    (Icons.money_rounded, 'Cash on Delivery'),
  ];

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    setState(() => _placing = true);
    final cart = context.read<CartController>();
    final coupon = context.read<CouponController>();
    final orders = context.read<OrderController>();

    final finalTotal = coupon.discountedTotal(cart.totalPrice);
    final error = await orders.placeOrder(
      items: cart.items,
      total: finalTotal,
      address: '123 Main Street, City',
      paymentMethod: _methods[_payIdx].$2,
    );

    if (!mounted) return;
    setState(() => _placing = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error));
      return;
    }

    cart.clearCart();
    coupon.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Order placed successfully! 🎉'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final coupon = context.watch<CouponController>();
    final finalTotal = coupon.discountedTotal(cart.totalPrice);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Delivery Address'),
            const SizedBox(height: 10),
            _AddressCard(),
            const SizedBox(height: 24),

            _label('Order Summary'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  ...cart.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(children: [
                          Expanded(
                              child: Text(item.product.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13))),
                          Text('x${item.quantity}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(width: 12),
                          Text(
                              '\$${((double.tryParse(item.product.price) ?? 0) * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ]),
                      )),
                  const Divider(color: AppColors.border, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _row('Subtotal', '\$${cart.totalPrice.toStringAsFixed(2)}'),
                      if (coupon.applied) ...[
                        const SizedBox(height: 6),
                        _row(
                            'Coupon (${(coupon.discount * 100).toInt()}% off)',
                            '-\$${(cart.totalPrice * coupon.discount).toStringAsFixed(2)}',
                            valueColor: AppColors.success),
                      ],
                      const SizedBox(height: 6),
                      _row('Delivery', 'Free', valueColor: AppColors.success),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: AppColors.border, height: 1)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                          ShaderMask(
                            shaderCallback: (b) =>
                                AppColors.ctaGradient.createShader(b),
                            child: Text('\$${finalTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18)),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Coupon
            _label('Coupon Code'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _couponCtrl,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Enter coupon (e.g. SAVE10)',
                    errorText: coupon.error,
                    suffixIcon: coupon.applied
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.success)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => context
                    .read<CouponController>()
                    .apply(_couponCtrl.text),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.ctaGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                      child: Text('Apply',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600))),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            _label('Payment Method'),
            const SizedBox(height: 10),
            ...List.generate(_methods.length, (i) {
              final active = i == _payIdx;
              return GestureDetector(
                onTap: () => setState(() => _payIdx = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: active ? AppColors.blue : AppColors.border,
                        width: active ? 1.5 : 1),
                  ),
                  child: Row(children: [
                    Icon(_methods[i].$1,
                        color: active
                            ? AppColors.blue
                            : AppColors.textSecondary,
                        size: 22),
                    const SizedBox(width: 12),
                    Text(_methods[i].$2,
                        style: TextStyle(
                            color: active
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 14)),
                    const Spacer(),
                    if (active)
                      Container(
                        width: 18, height: 18,
                        decoration: const BoxDecoration(
                            gradient: AppColors.ctaGradient,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.check,
                            size: 11, color: Colors.white),
                      ),
                  ]),
                ),
              );
            }),

            const SizedBox(height: 32),

            _placing
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.blue))
                : GradientButton(
                    label: 'Place Order  •  \$${finalTotal.toStringAsFixed(2)}',
                    onTap: _placeOrder,
                    icon: const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 16),
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700));

  Widget _row(String label, String value, {Color? valueColor}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            Text(value,
                style: TextStyle(
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13)),
          ],
        ),
      );
}

class _AddressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blue, width: 1.5),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.location_on_rounded,
              color: AppColors.blue, size: 18),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Home',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            SizedBox(height: 2),
            Text('123 Main Street, City, Country',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ]),
        ),
        const Icon(Icons.chevron_right_rounded,
            color: AppColors.textSecondary, size: 18),
      ]),
    );
  }
}
