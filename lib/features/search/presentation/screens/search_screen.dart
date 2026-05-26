import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_ai/core/theme/app_theme.dart';
import 'package:ecommerce_ai/core/utils/app_cache_manager.dart';
import 'package:ecommerce_ai/features/product/data/models/product_model.dart';
import 'package:ecommerce_ai/features/product/data/services/product_service.dart';
import 'package:ecommerce_ai/features/product/presentation/screens/product_details_screen.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                onChanged: (v) => setState(() => _q = v.toLowerCase()),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _q.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _ctrl.clear();
                            setState(() => _q = '');
                          })
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: _q.isEmpty
                  ? _buildEmpty()
                  : StreamBuilder<List<ProductModel>>(
                      stream: ProductService().getProducts(),
                      builder: (_, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.blue));
                        }
                        final results = (snap.data ?? [])
                            .where((p) =>
                                p.title.toLowerCase().contains(_q) ||
                                p.category.toLowerCase().contains(_q))
                            .toList();
                        if (results.isEmpty) {
                          return Center(
                            child: Text('No results for "$_q"',
                                style: const TextStyle(
                                    color: AppColors.textSecondary)),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          physics: const BouncingScrollPhysics(),
                          itemCount: results.length,
                          itemBuilder: (_, i) =>
                              _ResultTile(product: results[i]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 56, color: AppColors.border),
          SizedBox(height: 12),
          Text('Search for products',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final ProductModel product;
  const _ResultTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: product.image,
                cacheManager: AppCacheManager.instance,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: AppColors.bgSecondary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(product.category,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (b) => AppColors.ctaGradient.createShader(b),
              child: Text('\$${product.price}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
