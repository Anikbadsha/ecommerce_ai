import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_ai/core/theme/app_theme.dart';
import 'package:ecommerce_ai/core/utils/app_cache_manager.dart';
import 'package:ecommerce_ai/core/widgets/product_card.dart';
import 'package:ecommerce_ai/features/cart/controller/cart_controller.dart';
import 'package:ecommerce_ai/features/product/data/models/product_model.dart';
import 'package:ecommerce_ai/features/product/data/services/product_service.dart';
import 'package:ecommerce_ai/features/product/presentation/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  // Stream created ONCE in initState — never recreated on rebuild
  late final Stream<List<ProductModel>> _productStream;

  final _searchCtrl = TextEditingController();
  String _query = '';
  int _bannerIndex = 0;
  int _selectedCategory = 0;

  // Cached product list — only updated when Firestore emits
  List<ProductModel> _allProducts = [];

  // Pagination state — extra pages loaded on demand
  final List<ProductModel> _extraProducts = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _loadingMore = false;

  static const _banners = [
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&q=80&fit=crop',
    'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=800&q=80&fit=crop',
    'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800&q=80&fit=crop',
  ];

  static const _categories = [
    ('All', Icons.grid_view_rounded),
    ('Electronics', Icons.devices_rounded),
    ('Fashion', Icons.checkroom_rounded),
    ('Jewelry', Icons.diamond_rounded),
    ('Home', Icons.home_rounded),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _productStream = ProductService().getProducts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ProductModel> get _filtered {
    // Merge stream page + any extra pages loaded on demand
    final combined = [..._allProducts, ..._extraProducts];
    // Deduplicate by id in case stream and paginated fetch overlap
    final seen = <String>{};
    final deduped = combined.where((p) => seen.add(p.id)).toList();

    final cat = _categories[_selectedCategory].$1;
    return deduped.where((p) {
      final matchQuery = p.title.toLowerCase().contains(_query);
      final matchCat = cat == 'All' ||
          p.category.toLowerCase().contains(cat.toLowerCase());
      return matchQuery && matchCat;
    }).toList();
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await ProductService().getProductsPage(lastDoc: _lastDoc);
      setState(() {
        _extraProducts.addAll(page.products);
        _lastDoc = page.lastDoc;
        _hasMore = page.hasMore;
      });
    } catch (_) {
      // Non-critical — user can retry by tapping again
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _topBar(context),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _banner(),
                    const SizedBox(height: 24),
                    _categories_(),
                    const SizedBox(height: 24),
                    _sectionHeader(),
                    const SizedBox(height: 16),
                    _productGrid(),
                    if (_hasMore && _query.isEmpty && _selectedCategory == 0)
                      _loadMoreButton(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (b) => AppColors.ctaGradient.createShader(b),
                child: const Text('NeoShop',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
              ),
              const Spacer(),
              // Cart badge — Selector so only badge rebuilds on cart change
              Selector<CartController, int>(
                selector: (_, c) => c.itemCount,
                builder: (_, itemCount, _) => Stack(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          size: 20, color: AppColors.textPrimary),
                    ),
                    if (itemCount > 0)
                      Positioned(
                        right: 0, top: 0,
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(
                              gradient: AppColors.ctaGradient,
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text('$itemCount',
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.notifications_outlined,
                    size: 20, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search products, brands...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded, size: 18))
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _banner() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: true,
            enlargeFactor: 0.12,
            viewportFraction: 0.88,
            onPageChanged: (i, _) => setState(() => _bannerIndex = i),
          ),
          items: _banners.map((url) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: url,
                    cacheKey: url,
                    cacheManager: AppCacheManager.instance,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(color: AppColors.card),
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.card),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.transparent,
                          AppColors.bg.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20, left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: AppColors.ctaGradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('SALE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 6),
                        const Text('Up to 50% Off',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        AnimatedSmoothIndicator(
          activeIndex: _bannerIndex,
          count: _banners.length,
          effect: const WormEffect(
            dotHeight: 6, dotWidth: 6,
            activeDotColor: AppColors.blue,
            dotColor: AppColors.border,
          ),
        ),
      ],
    );
  }

  Widget _categories_() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Categories',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final active = i == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: active ? AppColors.ctaGradient : null,
                    color: active ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: active ? Colors.transparent : AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_categories[i].$2,
                          size: 22,
                          color: active ? Colors.white : AppColors.textSecondary),
                      const SizedBox(height: 6),
                      Text(_categories[i].$1,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: active
                                  ? Colors.white
                                  : AppColors.textSecondary)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text('Featured Products',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                gradient: AppColors.ctaGradient,
                borderRadius: BorderRadius.circular(6)),
            child: const Text('HOT',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          const Text('See all',
              style: TextStyle(color: AppColors.blue, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _productGrid() {
    return StreamBuilder<List<ProductModel>>(
      stream: _productStream, // stable reference — never recreated
      builder: (context, snap) {
        if (snap.hasData) {
          _allProducts = snap.data!; // cache latest data
        }

        if (_allProducts.isEmpty &&
            snap.connectionState == ConnectionState.waiting) {
          return _shimmerGrid();
        }

        final products = _filtered;

        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No products found',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, i) {
            final p = products[i];
            return ProductCard(
              key: ValueKey(p.title), // stable key prevents card rebuild
              product: p,
              title: p.title,
              price: '\$${p.price}',
              image: p.image.isNotEmpty
                  ? p.image
                  : 'https://via.placeholder.com/300',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: p))),
              onAdd: () {
                context.read<CartController>().addToCart(p);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${p.title} added to cart'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
              },
            );
          },
        );
      },
    );
  }

  Widget _loadMoreButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _loadingMore ? null : _loadMore,
          child: _loadingMore
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.blue))
              : const Text('Load more',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _shimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20)),
        child: const _ShimmerBox(),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Container(
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: _anim.value + 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
