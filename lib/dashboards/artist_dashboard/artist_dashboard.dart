import 'package:artist_hub/dashboards/artist_dashboard/artist_home.dart';
import 'package:flutter/material.dart';
import 'package:artist_hub/shared/widgets/common_appbar/Common_Appbar.dart';
import 'package:artist_hub/dashboards/artist_dashboard/profile_screens.dart';
import 'package:artist_hub/dashboards/artist_dashboard/add_post_screens.dart';
import 'package:artist_hub/dashboards/artist_dashboard/booking_screens.dart';
import 'package:artist_hub/shared/Constants/app_colors.dart';

class ArtistDashboard extends StatefulWidget {
  const ArtistDashboard({super.key});

  @override
  State<ArtistDashboard> createState() => _ArtistDashboardState();
}

class _ArtistDashboardState extends State<ArtistDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ArtistHome(),
    ProfileScreens(),
    AddPostScreens(),
    BookingScreens(),
  ];

  // Create ShaderMask for gradient icon
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
    return Scaffold(
      appBar: CommonAppbar(title: 'Artist Dashboard'),
      body: _screens[_selectedIndex],
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
        type: BottomNavigationBarType.fixed, // Changed from 'shifting' to 'fixed'
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
            icon: _gradientIcon(Icons.person_outlined, _selectedIndex == 1, 24),
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
          BottomNavigationBarItem(
            icon: _gradientIcon(
              Icons.add_circle_outline,
              _selectedIndex == 2,
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
              _selectedIndex == 3,
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
        ],
      ),
    );
  }
}