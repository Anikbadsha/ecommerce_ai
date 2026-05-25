
import 'package:ecommerce_ai/core/widgets/main_navigation_screen.dart';
import 'package:ecommerce_ai/features/auth/controller/auth_controller.dart';
import 'package:ecommerce_ai/features/cart/controller/cart_controller.dart';
import 'package:ecommerce_ai/features/wishlist/controller/wishlist_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WishlistController(),
        ),

        ChangeNotifierProvider(
          create: (_) => CartController(),
        ),

        // ✅ AUTH CONTROLLER
        ChangeNotifierProvider(
          create: (_) => AuthController(),
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          brightness: Brightness.dark,

          scaffoldBackgroundColor: const Color(0xFF0F172A),

          primaryColor: const Color(0xFF6C63FF),

          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F172A),
            elevation: 0,
            centerTitle: false,
          ),

          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
          ),

          bottomNavigationBarTheme:
              const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF111827),
            selectedItemColor: Color(0xFF6C63FF),
            unselectedItemColor: Colors.grey,
          ),
        ),

        home: const MainNavigationScreen(),
      ),
    );
  }
}
