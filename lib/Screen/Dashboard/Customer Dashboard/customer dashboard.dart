import 'package:flutter/material.dart';
import '../../../Constants/app_colors.dart';
import '../../Shared Preference/shared_pref.dart';

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

  void _logout() async {
    await SharedPreferencesService.logout();
    // Navigate to login screen - update based on your routing
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Dashboard"),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.book, color: AppColors.primaryColor),
              title: Text('My Courses'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to My Courses screen
              },
            ),
            ListTile(
              leading: Icon(Icons.workspace_premium, color: AppColors.primaryColor),
              title: Text('Go Premium'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Premium screen
              },
            ),
            ListTile(
              leading: Icon(Icons.video_library, color: AppColors.primaryColor),
              title: Text('Saved Videos'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Saved Videos screen
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.primaryColor),
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Edit Profile screen
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
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
            SizedBox(height: 20),
            Text(
              'Welcome to Customer Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Customer ID: ${SharedPreferencesService.getUserId()}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add customer-specific functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('Explore Features'),
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
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}