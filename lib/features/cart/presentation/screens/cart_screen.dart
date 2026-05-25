import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_ai/core/theme/app_theme.dart';
import 'package:ecommerce_ai/core/widgets/gradient_button.dart';
import 'package:ecommerce_ai/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Text('My Cart',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(width: 8),
                  if (cart.items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: AppColors.ctaGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            cart.items.isEmpty
                ? Expanded(child: _buildEmpty())
                : Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            physics: const BouncingScrollPhysics(),
                            itemCount: cart.items.length,
                            itemBuilder: (_, i) =>
                                _CartItem(item: cart.items[i], cart: cart),
                          ),
                        ),
                        _buildCheckoutPanel(context, cart),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                size: 48, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          const Text('Your cart is empty',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Add items to get started',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCheckoutPanel(BuildContext context, CartController cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: cart.totalPrice),
          const SizedBox(height: 8),
          const _SummaryRow(label: 'Delivery', value: 0, isFree: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border),
          ),
          _SummaryRow(
              label: 'Total',
              value: cart.totalPrice,
              isBold: true),
          const SizedBox(height: 16),
          GradientButton(
            label: 'Proceed to Checkout',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen())),
            icon: const Icon(Icons.lock_rounded, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final dynamic item;
  final CartController cart;

  const _CartItem({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.product.image.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.product.image,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.bgSecondary),
                  )
                : Container(
                    width: 72,
                    height: 72,
                    color: AppColors.bgSecondary,
                    child: const Icon(Icons.shopping_bag_rounded,
                        color: AppColors.blue),
                  ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                ShaderMask(
                  shaderCallback: (b) => AppColors.ctaGradient.createShader(b),
                  child: Text(
                    '\$${item.product.price}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Qty controls
          Column(
            children: [
              _QtyBtn(
                icon: Icons.add,
                onTap: () => cart.increaseQty(item),
                active: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              _QtyBtn(
                icon: Icons.remove,
                onTap: () => cart.decreaseQty(item),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _QtyBtn({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          gradient: active ? AppColors.ctaGradient : null,
          color: active ? null : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(8),
          border: active ? null : Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isFree;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isFree = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            )),
        isFree
            ? const Text('Free',
                style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 14))
            : Text(
                '\$${value.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isBold ? AppColors.gradEnd : AppColors.textPrimary,
                  fontSize: isBold ? 18 : 14,
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
      ],
    );
  }
}
