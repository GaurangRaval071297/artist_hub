import 'package:flutter/material.dart';
import 'package:artist_hub/shared/preferences/shared_preferences.dart';
import '../../auth/login_screen.dart';
import '../customer_dashboard/customer_home_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0;
  late String userName;
  late String userEmail;

  @override
  void initState() {
    super.initState();
    userName = SharedPreferencesHelper.userName;
    userEmail = SharedPreferencesHelper.userEmail;
  }

  List<Widget> _buildScreens() {
    return [
      CustomerHomeScreen(),
      Container(child: Center(child: Text('Search'))),
      Container(child: Center(child: Text('Bookings'))),
      Container(child: Center(child: Text('Profile'))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          userName.isNotEmpty ? 'Welcome, $userName' : 'Customer Dashboard',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await SharedPreferencesHelper.clearAll();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }
}