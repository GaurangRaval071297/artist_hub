import 'package:flutter/material.dart';
import 'package:artist_hub/shared/preferences/shared_preferences.dart';
import 'package:artist_hub/splash_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferencesHelper.init();

  print('=== APP START - SHARED PREFERENCES ===');
  print('isLoggedIn: ${SharedPreferencesHelper.isUserLoggedIn}');
  print('userType: ${SharedPreferencesHelper.userType}');
  print('userId: ${SharedPreferencesHelper.userId}');
  print('userEmail: ${SharedPreferencesHelper.userEmail}');
  print('userName: ${SharedPreferencesHelper.userName}');
  print('isFirstTime: ${SharedPreferencesHelper.isFirstTime}');
  print('====================================');

  runApp(const MyApp()); // ✅ MultiProvider નથી
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artist Hub',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}