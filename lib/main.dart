import 'package:flutter/material.dart';
import 'package:artist_hub/Screen/Shared Preference/shared_pref.dart';
import 'package:artist_hub/Screen/Splash Screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SharedPreferencesService.init();
    SharedPreferencesService.printAllData();
  } catch (e) {
    print('Error initializing SharedPreferences: $e');
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
      home: const SplashScreen(), // Direct splash screen
    );
  }
}