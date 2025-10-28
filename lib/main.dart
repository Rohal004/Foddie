import 'package:flutter/material.dart';
// No Firebase initialization for local sqflite backend.
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';
import 'app_navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // For development/demo: do not set Stripe.publishableKey on web where
  // flutter_stripe may access platform-specific APIs. Only set on mobile.
  if (!kIsWeb) {
    // For local development leave empty to avoid misconfiguration; set a
    // real publishable key in staging/prod.
    Stripe.publishableKey = '';
  }
  // Optionally set merchant identifier for Apple Pay if used in production:
  // Stripe.merchantIdentifier = 'merchant.com.your.id';
  runApp(const FoddieApp());
}

class FoddieApp extends StatelessWidget {
  const FoddieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        title: 'Foddie',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkGreenTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
