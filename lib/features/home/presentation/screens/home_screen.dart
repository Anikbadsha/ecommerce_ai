import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../../core/widgets/product_card.dart';
import '../../../cart/controller/cart_controller.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/presentation/screens/product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ProductModel> products = [
    ProductModel(
      title: 'Premium Shoes',
      price: '\$120',
      description: 'Premium sneakers for comfort.',
      image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
    ),
    ProductModel(
      title: 'Smart Watch',
      price: '\$180',
      description: 'Health tracking smartwatch.',
      image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
    ),
    ProductModel(
      title: 'Gaming Headset',
      price: '\$90',
      description: 'Immersive gaming sound.',
      image: 'https://images.unsplash.com/photo-1583394838336-acd977736f90',
    ),
    ProductModel(
      title: 'Modern Hoodie',
      price: '\$70',
      description: 'Soft premium hoodie.',
      image: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',
    ),
    ProductModel(
      title: 'Wireless Mouse',
      price: '\$40',
      description: 'Smooth wireless mouse.',
      image: 'https://images.unsplash.com/photo-1527814050087-3793815479db',
    ),
    ProductModel(
      title: 'Leather Bag',
      price: '\$150',
      description: 'Premium leather bag.',
      image: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa',
    ),
  ];
  final List<String> bannerImages = [
  'https://images.unsplash.com/photo-1441986300917-64674bd600d8',
  'https://images.unsplash.com/photo-1523381210434-271e8be1f52b',
  'https://images.unsplash.com/photo-1483985988355-763728e1935b',
];

  late List<ProductModel> filteredProducts;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredProducts = List.from(products);
  }

  void searchProducts(String query) {
    setState(() {
      filteredProducts = products
          .where((p) =>
              p.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ecommerce AI"),

        actions: [
          Consumer<CartController>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {},
                  ),

                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cart.itemCount.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: searchProducts,
                decoration: InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ RESPONSIVE BANNER (FIXED)
// AUTO SLIDER BANNER
CarouselSlider(
  options: CarouselOptions(
    height: MediaQuery.of(context).size.height * 0.23,
    autoPlay: true,
    enlargeCenterPage: true,
    viewportFraction: 0.92,
    autoPlayInterval: const Duration(seconds: 3),
  ),

  items: bannerImages.map((image) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 5),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),

            image: DecorationImage(
              image: NetworkImage(image),
              fit: BoxFit.cover,
            ),
          ),

          child: Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),

              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),

            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisAlignment:
                  MainAxisAlignment.end,

              children: [

                Text(
                  "Summer Collection",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "Up to 50% OFF",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }).toList(),
),

            const SizedBox(height: 20),

            // TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Featured Products",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // GRID
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.7,
              ),

              itemBuilder: (context, index) {
                final product = filteredProducts[index];

                return ProductCard(
                  product: product,
                  title: product.title,
                  price: product.price,
                  image: product.image,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailsScreen(product: product),
                      ),
                    );
                  },

                  onAdd: () {
                    cart.addToCart(product);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${product.title} added to cart'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}