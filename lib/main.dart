import 'package:ecommerce_ai/core/widgets/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/cart/controller/cart_controller.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartController(),
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.dark,
          ),
        ),

        home: const MainNavigationScreen(),
      ),
    );
  }
}