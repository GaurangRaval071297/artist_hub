import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:artist_hub/Screen/Auth/Login.dart';
import 'package:artist_hub/Screen/Connection/connectivity_screen.dart';
import 'package:artist_hub/Screen/Dashboard/Artist Dashboard/artist_dashboard.dart';
import 'package:artist_hub/Screen/Dashboard/Customer Dashboard/customer dashboard.dart';
import 'package:artist_hub/Screen/Shared Preference/shared_pref.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isChecking = true;
  String _statusMessage = 'Initializing app...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Wait minimum 2 seconds for splash
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _statusMessage = 'Checking connectivity...';
      });

      // Step 2: Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi);

      if (!hasInternet) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ConnectivityErrorScreen()),
          );
        }
        return;
      }

      setState(() {
        _statusMessage = 'Checking login status...';
      });

      // Step 3: Check if SharedPreferences is initialized
      if (!SharedPreferencesService.isInitialized) {
        print('⚠️ SharedPreferences not initialized, attempting to initialize...');
        await SharedPreferencesService.init();
      }

      // Step 4: Check login status
      bool isLoggedIn = SharedPreferencesService.isLoggedIn();

      print('🔍 Login Status: $isLoggedIn');

      if (isLoggedIn) {
        String userRole = SharedPreferencesService.getUserRole().toLowerCase();
        String userName = SharedPreferencesService.getUserName();

        print('👤 User Role: $userRole');
        print('👤 User Name: $userName');
        print('🔍 All User Data: ${SharedPreferencesService.getUserData()}');

        // Debug: Print all stored data
        SharedPreferencesService.printAllData();

        // Navigate based on role
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 500));

          if (userRole == 'artist') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ArtistDashboard()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CustomerDashboard()),
            );
          }
        }
      } else {
        // Not logged in, go to login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      }
    } catch (e) {
      print('❌ Error in splash screen: $e');

      // Fallback to login screen on any error
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.palette,
                size: 60,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 30),

            // App Name with gradient
            Text(
              'Artist Hub',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [Colors.deepPurple, Colors.pink],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),

            const SizedBox(height: 10),

            // Tagline
            const Text(
              'Connect • Create • Inspire',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 50),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),

            const SizedBox(height: 15),

            // Status message
            Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // Version
            const Text(
              'v1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}