import 'package:ecommerce_ai/features/cart/presentation/screens/cart_screen.dart';
import 'package:ecommerce_ai/features/home/presentation/screens/home_screen.dart';
import 'package:ecommerce_ai/features/profile/presentation/screens/profile_screen.dart';
import 'package:ecommerce_ai/features/search/presentation/screens/search_screen.dart';
import 'package:ecommerce_ai/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _idx = 0;

  static const _screens = [
    HomeScreen(),
    SearchScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.search_rounded, 'Search'),
    (Icons.favorite_rounded, 'Wishlist'),
    (Icons.shopping_bag_rounded, 'Cart'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.bgSecondary.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x55000000), blurRadius: 24, offset: Offset(0, 8))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final active = i == _idx;
              return GestureDetector(
                onTap: () => setState(() => _idx = i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (b) => active
                            ? AppColors.ctaGradient.createShader(b)
                            : const LinearGradient(colors: [
                                AppColors.textSecondary,
                                AppColors.textSecondary
                              ]).createShader(b),
                        child: Icon(_items[i].$1,
                            size: active ? 26 : 22, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(_items[i].$2,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            color: active
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
