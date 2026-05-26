import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_ai/core/theme/app_theme.dart';
import 'package:ecommerce_ai/core/utils/app_cache_manager.dart';
import 'package:ecommerce_ai/core/widgets/gradient_button.dart';
import 'package:ecommerce_ai/features/cart/controller/cart_controller.dart';
import 'package:ecommerce_ai/features/product/data/models/product_model.dart';
import 'package:ecommerce_ai/features/wishlist/controller/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final price = double.tryParse(p.price) ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Hero gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.2,
                  colors: [
                    AppColors.gradStart.withValues(alpha: 0.18),
                    AppColors.bg,
                  ],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // IMAGE SECTION
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    // Product image
                    p.image.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: p.image,
                            cacheManager: AppCacheManager.instance,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.blue),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.shopping_bag_rounded,
                                size: 120, color: AppColors.blue),
                          ),

                    // Back button
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CircleBtn(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () => Navigator.pop(context),
                            ),
                            Consumer<WishlistController>(
                              builder: (_, wishlist, _) {
                                final isFav = wishlist.isExist(p);
                                return _CircleBtn(
                                  icon: isFav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  iconColor: isFav
                                      ? AppColors.error
                                      : AppColors.textPrimary,
                                  onTap: () => wishlist.toggleWishlist(p),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // DETAILS SHEET
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  decoration: const BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.category.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.blue,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Title + Price row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                p.title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ShaderMask(
                              shaderCallback: (b) =>
                                  AppColors.ctaGradient.createShader(b),
                              child: Text(
                                '\$${price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Rating + sold
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < 4
                                    ? Icons.star_rounded
                                    : Icons.star_half_rounded,
                                size: 18,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('4.8',
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            const Text('(2.4k reviews)',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Trust badges
                        Row(
                          children: [
                            _TrustBadge(
                                icon: Icons.verified_rounded,
                                label: 'Verified'),
                            const SizedBox(width: 8),
                            _TrustBadge(
                                icon: Icons.local_shipping_rounded,
                                label: 'Free Delivery'),
                            const SizedBox(width: 8),
                            _TrustBadge(
                                icon: Icons.replay_rounded,
                                label: '30-day Return'),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Description
                        const Text('Description',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(height: 8),
                        Text(
                          p.description.isNotEmpty
                              ? p.description
                              : 'Premium quality product with exceptional craftsmanship.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Quantity selector
                        Row(
                          children: [
                            const Text('Quantity',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                )),
                            const Spacer(),
                            _QtyButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (_qty > 1) setState(() => _qty--);
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$_qty',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _QtyButton(
                              icon: Icons.add,
                              onTap: () => setState(() => _qty++),
                              active: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Add to cart
                        GradientButton(
                          label:
                              'Add to Cart  •  \$${(price * _qty).toStringAsFixed(2)}',
                          onTap: () {
                            for (var i = 0; i < _qty; i++) {
                              context.read<CartController>().addToCart(p);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${p.title} added to cart'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_bag_rounded,
                              color: Colors.white, size: 18),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.blue),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _QtyButton(
      {required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: active ? AppColors.ctaGradient : null,
          color: active ? null : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: active ? null : Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}
