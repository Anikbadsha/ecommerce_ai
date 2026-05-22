import 'package:ecommerce_ai/features/product/data/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required ProductModel product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Column(
          children: [

            // TOP IMAGE SECTION
            Expanded(
              flex: 5,
              child: Stack(
                children: [

                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                    ),

                    child: const Center(
                      child: Icon(
                        Icons.shopping_bag,
                        size: 140,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 20,
                    left: 20,
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 20,
                    right: 20,
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // DETAILS SECTION
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),

                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [

                        const Text(
                          'Premium Sneakers',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Text(
                          '\$120',
                          style: TextStyle(
                            fontSize: 28,
                            color: Color(0xFF22D3EE),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: const [

                        Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),

                        SizedBox(width: 8),

                        Text(
                          '4.8 Ratings',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Text(
                      'Premium quality sneakers designed for comfort and modern fashion style.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade400,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Select Size',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [

                        _buildSize('39'),
                        _buildSize('40'),
                        _buildSize('41'),
                        _buildSize('42'),

                      ],
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 65,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF6C63FF),

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                        ),

                        onPressed: () {},

                        child: const Text(
                          'Add To Cart',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Widget _buildSize(String size) {
    return Container(
      margin: const EdgeInsets.only(right: 14),

      height: 55,
      width: 55,

      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Center(
        child: Text(
          size,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}