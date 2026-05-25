import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_ai/features/product/data/models/product_model.dart';
import 'package:ecommerce_ai/features/wishlist/controller/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final String title;
  final String price;
  final String image;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.title,
    required this.price,
    required this.image,
    required this.onTap,
    required this.onAdd,
    // kept for API compatibility but unused in UI
    String category = '',
    String description = '',
    String imageUrl = '',
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _added = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    // Bounce animation
    await _ctrl.forward();
    await _ctrl.reverse();

    widget.onAdd();

    // Brief "added" checkmark feedback
    if (!mounted) return;
    setState(() => _added = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _added = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 20, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE 65%
            Expanded(
              flex: 65,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: widget.image,
                      cacheKey: widget.image, // prevents re-fetch on rebuild
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (_, __) => Container(
                        color: AppColors.bgSecondary,
                        child: const Center(
                          child: SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.blue),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.bgSecondary,
                        child: const Icon(Icons.image_not_supported,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  // Wishlist — scoped Consumer so only this icon rebuilds
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Selector<WishlistController, bool>(
                      selector: (_, w) => w.isExist(widget.product),
                      builder: (ctx, isFav, child) => GestureDetector(
                        onTap: () => context
                            .read<WishlistController>()
                            .toggleWishlist(widget.product),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.bg.withValues(alpha: 0.75),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFav ? AppColors.error : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // DETAILS 35%
            Expanded(
              flex: 35,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(children: const [
                      Icon(Icons.star_rounded, size: 12, color: AppColors.warning),
                      SizedBox(width: 2),
                      Text('4.8',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)),
                    ]),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.price,
                          style: const TextStyle(
                            color: AppColors.gradEnd,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        // Animated add button with feedback
                        ScaleTransition(
                          scale: _scale,
                          child: GestureDetector(
                            onTap: _handleAdd,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                gradient: _added
                                    ? const LinearGradient(
                                        colors: [AppColors.success, AppColors.success])
                                    : AppColors.ctaGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _added ? Icons.check : Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
