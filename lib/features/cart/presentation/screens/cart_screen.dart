import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),

      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty 🛒',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [

                // CART ITEMS LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,

                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),

                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Row(
                          children: [

                            // PRODUCT ICON
                            const Icon(
                              Icons.shopping_bag,
                              size: 50,
                              color: Color(0xFF6C63FF),
                            ),

                            const SizedBox(width: 12),

                            // TITLE + PRICE
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    item.product.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    item.product.price,
                                    style: const TextStyle(
                                      color: Color(0xFF22D3EE),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    'Qty: ${item.quantity}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ACTIONS
                            Column(
                              children: [

                                IconButton(
  onPressed: () {
    cart.increaseQty(item);
  },
  icon: const Icon(Icons.add),
),

IconButton(
  onPressed: () {
    cart.decreaseQty(item);
  },
  icon: const Icon(Icons.remove),
),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // TOTAL SECTION
                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        'Total: \$${cart.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                          ),

                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text('Checkout Coming Soon 🚀'),
                              ),
                            );
                          },

                          child: const Text('Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}