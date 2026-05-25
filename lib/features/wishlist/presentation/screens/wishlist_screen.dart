import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../product/presentation/screens/product_details_screen.dart';
import '../../controller/wishlist_controller.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistController>(
      builder: (context, wishlist, child) {

        final items = wishlist.wishlist;

        return Scaffold(
          appBar: AppBar(
            title: const Text("My Wishlist"),
          ),

          body: items.isEmpty
              ? const Center(
                  child: Text(
                    'No wishlist items yet ❤️',
                    style: TextStyle(fontSize: 18),
                  ),
                )

              : GridView.builder(
                  padding: const EdgeInsets.all(16),

                  itemCount: items.length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.68,
                  ),

                  itemBuilder: (context, index) {

                    final product = items[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(12),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            // IMAGE
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(18),

                                child: Image.network(
                                  product.image,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              product.price,
                              style: const TextStyle(
                                color: Color(0xFF22D3EE),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [

                                Expanded(
                                  child: ElevatedButton(
                                    style:
                                        ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF6C63FF),
                                    ),

                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ProductDetailsScreen(
                                            product: product,
                                          ),
                                        ),
                                      );
                                    },

                                    child: Text("View",style: TextStyle(fontSize:MediaQuery.of(context).size.width * 0.035,),  

                                  ),
                                ),),

                                const SizedBox(width: 8),

                                IconButton(
                                  onPressed: () {
                                    wishlist.toggleWishlist(product);
                                  },

                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}