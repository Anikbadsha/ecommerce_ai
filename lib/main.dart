import 'package:ecommerce_ai/core/theme/app_theme.dart';
import 'package:ecommerce_ai/features/auth/controller/auth_controller.dart';
import 'package:ecommerce_ai/features/cart/controller/cart_controller.dart';
import 'package:ecommerce_ai/features/checkout/controller/coupon_controller.dart';
import 'package:ecommerce_ai/features/orders/controller/order_controller.dart';
import 'package:ecommerce_ai/features/wishlist/controller/wishlist_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await Firebase.initializeApp();

  // ── Crashlytics ──────────────────────────────────────────────────────────
  // Route all Flutter framework errors to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Route async errors that escape the Flutter framework (e.g. isolates)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // ── App Check ────────────────────────────────────────────────────────────
  // Play Integrity for release builds; debug provider for local development.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kReleaseMode
        ? AndroidPlayIntegrityProvider()
        : AndroidDebugProvider(),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WishlistController()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => CouponController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NeoShop',
        theme: AppTheme.dark,
        home: const AuthGate(),
      ),
    );
  }
}
