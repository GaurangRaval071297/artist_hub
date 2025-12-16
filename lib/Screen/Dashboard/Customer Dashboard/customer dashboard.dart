import 'package:flutter/material.dart';
import '../../../Constants/app_colors.dart';
import '../../Shared Preference/shared_pref.dart';
import '../../Auth/Login.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
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

  Future<void> _logout() async {
    await SharedPreferencesService.clearAllData();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Dashboard"),
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
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.appBarGradient.colors[0].withOpacity(0.9),
                    AppColors.appBarGradient.colors[1].withOpacity(0.7),
                  ],
                ),
              ),
              accountName: Text(
                userName.isNotEmpty ? userName : 'Customer',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                userEmail.isNotEmpty ? userEmail : 'customer@example.com',
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: AppColors.primaryColor,
                  size: 40,
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
              leading: Icon(Icons.book, color: AppColors.primaryColor),
              title: const Text('My Courses'),
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
              leading: Icon(Icons.video_library, color: AppColors.primaryColor),
              title: const Text('Saved Videos'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.primaryColor),
              title: const Text('Edit Profile'),
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
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 80,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Customer Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Customer ID: ${SharedPreferencesService.getUserId()}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Explore Features'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}