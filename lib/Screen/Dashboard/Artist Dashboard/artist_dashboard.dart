import 'package:flutter/material.dart';
import '../../../Constants/app_colors.dart';
import '../../Auth/Login.dart';
import '../../Shared Preference/shared_pref.dart';

class ArtistDashboard extends StatefulWidget {
  const ArtistDashboard({super.key});

  @override
  State<ArtistDashboard> createState() => _ArtistDashboardState();
}

class _ArtistDashboardState extends State<ArtistDashboard> {
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      userName = SharedPreferencesService.getUserName();
      userEmail = SharedPreferencesService.getUserEmail();
    });
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      await SharedPreferencesService.clearAllData();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
            (route) => false,
      );
    } catch (e) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Artist Dashboard"),
        leading: DrawerButton(color: AppColors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.appBarGradient.colors[0].withOpacity(0.9),
                AppColors.appBarGradient.colors[1].withOpacity(0.7),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppColors.white,
        child: ListView(
          children: [
            DrawerHeader(
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.appBarGradient.colors[0].withOpacity(0.9),
                      AppColors.appBarGradient.colors[1].withOpacity(0.7),
                    ],
                  ),
                ),
                accountName: Text(
                  userName.isNotEmpty ? userName : "Artist",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(userEmail.isNotEmpty ? userEmail : "artist@example.com"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : "A",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.appBarGradient.colors[0],
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: AppColors.primaryColor),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.palette, color: AppColors.primaryColor),
              title: const Text('My Artworks'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today, color: AppColors.primaryColor),
              title: const Text('Bookings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.workspace_premium, color: AppColors.primaryColor),
              title: const Text('Go Premium'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.video_label, color: AppColors.primaryColor),
              title: const Text('My Videos'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.person, color: AppColors.primaryColor),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: AppColors.primaryColor),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Artist Hub v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.palette,
              size: 100,
              color: AppColors.appBarGradient.colors[0],
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome Artist!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.appBarGradient.colors[0],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              userName.isNotEmpty ? 'Hello, $userName!' : 'Manage your art and bookings',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appBarGradient.colors[0],
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('View My Artworks'),
            ),
          ],
        ),
      ),
    );
  }
}