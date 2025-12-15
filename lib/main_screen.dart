import 'package:flutter/material.dart';
import 'package:artist_hub/Screen/Auth/Login.dart';
import 'package:artist_hub/Screen/Dashboard/Artist%20Dashboard/artist_dashboard.dart';
import 'Screen/Dashboard/Customer Dashboard/customer dashboard.dart';
import 'Screen/Shared Preference/shared_pref.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          // User is logged in, check role
          String userRole = SharedPreferencesService.getUserRole().toLowerCase();

          if (userRole == 'artist') {
            return ArtistDashboard();
          } else {
            return CustomerDashboard();
          }
        } else {
          // User is not logged in
          return Login();
        }
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    // Initialize SharedPreferences
    await SharedPreferencesService.init();

    // Check if user is logged in
    return SharedPreferencesService.isLoggedIn();
  }
}
