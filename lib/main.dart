import 'package:flutter/material.dart';
import 'Screen/Shared Preference/shared_pref.dart';
import 'Screen/Splash Screen/splash_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences before runApp
  try {
    await SharedPreferencesService.init();
    print('✅ SharedPreferences initialized successfully');
  } catch (e) {
    print('❌ Error initializing SharedPreferences: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artist Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(), // Start with SplashScreen
    );
  }
}