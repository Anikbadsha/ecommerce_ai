import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/product_card.dart';
import '../../../cart/controller/cart_controller.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/presentation/screens/product_details_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<ProductModel> products = [
    ProductModel(
      title: 'Premium Shoes',
      price: '\$120',
      description: 'Premium quality sneakers designed for comfort and fashion.',
    ),
    ProductModel(
      title: 'Smart Watch',
      price: '\$180',
      description: 'Modern smartwatch with health tracking.',
    ),
    ProductModel(
      title: 'Gaming Headset',
      price: '\$90',
      description: 'High-quality immersive sound headset.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ecommerce AI"),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 BANNER (RESTORED)
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "New Collection",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Discover premium products for you",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Featured Products",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 PRODUCTS GRID
            GridView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.70,
              ),

              itemBuilder: (context, index) {
                final product = products[index];

                return ProductCard(
  title: product.title,
  price: product.price,

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
        content: Text('${product.title} added to cart'),
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