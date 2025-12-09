import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../Auth/Login.dart';
import '../Connection/connectivity_screen.dart';
import '../Dashboard/Artist Dashboard/artist_dashboard.dart';
import '../Dashboard/Customer Dashboard/customer dashboard.dart';
import '../Shared Preference/shared_pref.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isChecking = true;
  bool _initializationError = false;

  @override
  void initState() {
    super.initState();
    _initializeAndCheck();
  }

  Future<void> _initializeAndCheck() async {
    try {
      // First check if SharedPreferences is initialized
      if (!SharedPreferencesService.isInitialized) {
        // Try to initialize it
        await SharedPreferencesService.init();
      }

      // Then proceed with normal flow
      await _checkInternetAndNavigate();
    } catch (e) {
      print('Initialization error: $e');
      setState(() {
        _initializationError = true;
        _isChecking = false;
      });

      // Fallback - go to login after delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    }
  }

  Future<void> _checkInternetAndNavigate() async {
    // Wait for 2 seconds for splash animation
    await Future.delayed(const Duration(seconds: 2));

    // Check internet connectivity
    final connectivityResult = await Connectivity().checkConnectivity();

    if (mounted) {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // Internet is available
        _checkLoginStatus();
      } else {
        // No internet, show connectivity error screen
        setState(() {
          _isChecking = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConnectivityErrorScreen()),
        );
      }
    }
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Check if user is already logged in using SharedPreferences
      bool isLoggedIn = SharedPreferencesService.isLoggedIn();

      if (mounted) {
        setState(() {
          _isChecking = false;
        });

        await Future.delayed(const Duration(milliseconds: 500));

        if (isLoggedIn) {
          // User is logged in, check role and navigate to appropriate dashboard
          String userRole = SharedPreferencesService.getUserRole();

          print("User is logged in with role: $userRole");

          if (userRole == 'artist') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ArtistDashboard()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CustomerDashboard()),
            );
          }
        } else {
          // User is not logged in, go to Login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        }
      }
    } catch (e) {
      print('Error checking login status: $e');
      // Fallback to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Centered content
          Center(
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

                // Error message if initialization failed
                if (_initializationError)
                  Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.orange,
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Initializing app...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  )
                else
                // Loading indicator with connectivity status
                  Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _isChecking ? 'Checking connection...' : 'Loading app...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Version/loading text
                const Text(
                  'v1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Created by text at the bottom
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Created by Gaurang Raval',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}