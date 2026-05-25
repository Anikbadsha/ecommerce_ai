import 'package:ecommerce_ai/core/widgets/main_navigation_screen.dart';
import 'package:ecommerce_ai/features/auth/controller/auth_controller.dart';
import 'package:ecommerce_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:ecommerce_ai/features/cart/controller/cart_controller.dart';
import 'package:ecommerce_ai/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:ecommerce_ai/features/orders/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _seenOnboarding;
  bool _synced = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _seenOnboarding = prefs.getBool('onboarding_done') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    if (_seenOnboarding == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF06070A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2F6BFF))),
      );
    }

    if (!_seenOnboarding!) return const OnboardingScreen();

    final auth = context.watch<AuthController>();
    if (!auth.isLoggedIn) {
      _synced = false;
      return const LoginScreen();
    }

    // Sync data once per login session
    if (!_synced) {
      _synced = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CartController>().syncAfterLogin();
        context.read<OrderController>().fetchOrders();
      });
    }

    return const MainNavigationScreen();
  }
}
