import 'package:ecommerce_ai/core/theme/app_theme.dart';
import 'package:ecommerce_ai/features/auth/controller/auth_controller.dart';
import 'package:ecommerce_ai/features/orders/controller/order_controller.dart';
import 'package:ecommerce_ai/features/orders/presentation/screens/orders_screen.dart';
import 'package:ecommerce_ai/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:ecommerce_ai/features/wishlist/controller/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    final orderCount = context.watch<OrderController>().orders.length;
    final wishlistCount = context.watch<WishlistController>().wishlist.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: user == null
            ? const Center(
                child: Text('No user found',
                    style: TextStyle(color: AppColors.textSecondary)))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Header with gradient
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topCenter,
                          radius: 1.5,
                          colors: [
                            AppColors.gradStart.withValues(alpha: 0.2),
                            AppColors.bg,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.ctaGradient,
                              border: Border.all(
                                  color: AppColors.border, width: 3),
                            ),
                            child: ClipOval(
                              child: user.photoURL != null
                                  ? Image.network(user.photoURL!,
                                      fit: BoxFit.cover)
                                  : const Icon(Icons.person_rounded,
                                      size: 44, color: Colors.white),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Text(
                            user.displayName ?? 'User',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            user.email ?? '',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 14),
                          ),

                          const SizedBox(height: 16),

                          // Stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _StatChip(label: 'Orders', value: '$orderCount'),
                              Container(width: 1, height: 32, color: AppColors.border,
                                  margin: const EdgeInsets.symmetric(horizontal: 20)),
                              _StatChip(label: 'Wishlist', value: '$wishlistCount'),
                              Container(width: 1, height: 32, color: AppColors.border,
                                  margin: const EdgeInsets.symmetric(horizontal: 20)),
                              const _StatChip(label: 'Reviews', value: '0'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Menu items
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _MenuSection(title: 'Account', items: [
                            _MenuItem(
                                icon: Icons.person_outline_rounded,
                                label: 'Edit Profile',
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
                            _MenuItem(
                                icon: Icons.location_on_outlined,
                                label: 'Addresses',
                                onTap: () {}),
                            _MenuItem(
                                icon: Icons.payment_rounded,
                                label: 'Payment Methods',
                                onTap: () {}),
                          ]),

                          const SizedBox(height: 16),

                          _MenuSection(title: 'Orders', items: [
                            _MenuItem(
                                icon: Icons.receipt_long_rounded,
                                label: 'My Orders',
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const OrdersScreen()))),
                            _MenuItem(
                                icon: Icons.local_shipping_rounded,
                                label: 'Track Order',
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const OrdersScreen()))),
                            _MenuItem(
                                icon: Icons.replay_rounded,
                                label: 'Returns',
                                onTap: () {}),
                          ]),

                          const SizedBox(height: 16),

                          _MenuSection(title: 'Support', items: [
                            _MenuItem(
                                icon: Icons.help_outline_rounded,
                                label: 'Help Center',
                                onTap: () {}),
                            _MenuItem(
                                icon: Icons.chat_bubble_outline_rounded,
                                label: 'Live Chat',
                                onTap: () {}),
                          ]),

                          const SizedBox(height: 16),

                          // Logout
                          GestureDetector(
                            onTap: () async => await auth.logout(),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.error.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_rounded,
                                      color: AppColors.error, size: 20),
                                  SizedBox(width: 8),
                                  Text('Sign Out',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      )),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (b) => AppColors.ctaGradient.createShader(b),
          child: Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              )),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast)
                    const Divider(
                        height: 1, color: AppColors.border, indent: 52),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
