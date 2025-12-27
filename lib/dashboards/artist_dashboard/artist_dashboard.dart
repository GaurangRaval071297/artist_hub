import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artist_hub/providers/auth_provider.dart';
import 'package:artist_hub/shared/widgets/common_appbar/Common_Appbar.dart';
import 'package:artist_hub/shared/Constants/app_colors.dart';
import '../../auth/login_screen.dart';
import '../../shared/preferences/shared_preferences.dart';
import 'artist_home.dart';
import 'profile_screens.dart';
import 'add_post_screens.dart';
import 'booking_screens.dart';

class ArtistDashboard extends StatefulWidget {
  final String? id;
  const ArtistDashboard({this.id, super.key});

  @override
  State<ArtistDashboard> createState() => _ArtistDashboardState();
}

class _ArtistDashboardState extends State<ArtistDashboard> {
  int _selectedIndex = 0;

  // Create screens with auth provider access
  List<Widget> _buildScreens(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return [
      ArtistHome(id: authProvider.userId.isNotEmpty ? authProvider.userId : widget.id ?? ''),
      AddPostScreens(artistId: authProvider.userId),
      BookingScreens(userId: authProvider.userId, userType: 'artist'),
      ProfileScreens(userId: authProvider.userId), // ✅ Profile last position
    ];
  }

  // Create gradient icon
  Widget _gradientIcon(IconData icon, bool isSelected, double size) {
    if (!isSelected) {
      return Icon(icon, size: size, color: Colors.grey);
    }

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return AppColors.appBarGradient.createShader(bounds);
      },
      child: Icon(icon, size: size, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screens = _buildScreens(context);

    return Scaffold(
      appBar: CommonAppbar(
        title: authProvider.userName.isNotEmpty
            ? 'Welcome, ${authProvider.userName}'
            : 'Artist Dashboard',
        showDrawerIcon: true,
      ),
      drawer: _buildDrawer(context, authProvider),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 10,
        selectedItemColor: Colors.transparent,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: _gradientIcon(Icons.home_outlined, _selectedIndex == 0, 24),
            activeIcon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.appBarGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.home, size: 24, color: Colors.white),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _gradientIcon(
              Icons.add_circle_outline,
              _selectedIndex == 1,
              24,
            ),
            activeIcon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.appBarGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_circle, size: 24, color: Colors.white),
            ),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: _gradientIcon(
              Icons.calendar_today_outlined,
              _selectedIndex == 2,
              24,
            ),
            activeIcon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.appBarGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_today, size: 24, color: Colors.white),
            ),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: _gradientIcon(Icons.person_outlined, _selectedIndex == 3, 24),
            activeIcon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.appBarGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 24, color: Colors.white),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: AppColors.appBarGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.appBarGradient.colors[0],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  authProvider.userName.isNotEmpty
                      ? authProvider.userName
                      : 'Artist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  authProvider.userEmail.isNotEmpty
                      ? authProvider.userEmail
                      : 'artist@example.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.grey[700]),
            title: Text('Home'),
            onTap: () {
              setState(() {
                _selectedIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.add_photo_alternate, color: Colors.grey[700]),
            title: Text('Add Post'),
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_month, color: Colors.grey[700]),
            title: Text('My Bookings'),
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.grey[700]),
            title: Text('Profile'),
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey[700]),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: Colors.grey[700]),
            title: Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
            onPressed: () async {
              Navigator.pop(context);

              // Clear SharedPreferences
              await SharedPreferencesHelper.clearAll();

              // Clear Provider
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              authProvider.logout();

              // Navigate to Login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}