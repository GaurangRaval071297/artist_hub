import 'package:artist_hub/dashboards/artist_dashboard/add_artist_profile.dart';
import 'package:artist_hub/dashboards/artist_dashboard/artist_add_post.dart';
import 'package:artist_hub/dashboards/artist_dashboard/artist_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:artist_hub/shared/constants/app_colors.dart';
import 'artist_booking_screen.dart';
import 'artist_home_screen.dart';

class ArtistDashboard extends StatefulWidget {
  final String id;

  const ArtistDashboard({super.key, required this.id});

  @override
  State<ArtistDashboard> createState() => _ArtistDashboardState();
}

class _ArtistDashboardState extends State<ArtistDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ArtistHomePage(),
    const ArtistAddPost(),
    const ArtistBookingScreen(),
    const ArtistProfileScreen(),
    const AddArtistProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('ArtistDashboard opened with ID: ${widget.id}');

    final gradientColors = AppColors.appBarGradient.colors;
    final primaryColor = gradientColors[0];
    final secondaryColor = gradientColors[1];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist Dashboard'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.9),
                secondaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(
        primaryColor,
        secondaryColor,
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(
      Color primaryColor,
      Color secondaryColor,
      ) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.grey[600],
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 12,
      backgroundColor: Colors.white,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      iconSize: 24,
      items: [
        // Home
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _selectedIndex == 0
                  ? LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: _selectedIndex == 0 ? null : Colors.transparent,
            ),
            child: Icon(
              _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
              color: _selectedIndex == 0 ? Colors.white : Colors.grey[600],
              size: _selectedIndex == 0 ? 22 : 20,
            ),
          ),
          label: 'Home',
        ),

        // Add Post
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _selectedIndex == 1
                  ? LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  secondaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: _selectedIndex == 1
                    ? Colors.transparent
                    : primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: _selectedIndex == 1
                  ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
                  : null,
            ),
            child: Icon(
              _selectedIndex == 1 ? Icons.add : Icons.add_circle_outline,
              color: _selectedIndex == 1 ? Colors.white : primaryColor,
              size: _selectedIndex == 1 ? 24 : 22,
            ),
          ),
          label: 'Add Post',
        ),

        // Bookings
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _selectedIndex == 2
                  ? LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: _selectedIndex == 2 ? null : Colors.transparent,
            ),
            child: Icon(
              _selectedIndex == 2
                  ? Icons.calendar_today
                  : Icons.calendar_today_outlined,
              color: _selectedIndex == 2 ? Colors.white : Colors.grey[600],
              size: _selectedIndex == 2 ? 22 : 20,
            ),
          ),
          label: 'Bookings',
        ),

        // Profile
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _selectedIndex == 3
                  ? LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: _selectedIndex == 3 ? null : Colors.transparent,
            ),
            child: Icon(
              _selectedIndex == 3 ? Icons.person : Icons.person_outline,
              color: _selectedIndex == 3 ? Colors.white : Colors.grey[600],
              size: _selectedIndex == 3 ? 22 : 20,
            ),
          ),
          label: 'Profile',
        ),

        // Add Artist Profile
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _selectedIndex == 4
                  ? LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: _selectedIndex == 4 ? null : Colors.transparent,
            ),
            child: Icon(
              _selectedIndex == 4 ? Icons.add_box : Icons.add_box_outlined,
              color: _selectedIndex == 4 ? Colors.white : Colors.grey[600],
              size: _selectedIndex == 4 ? 22 : 20,
            ),
          ),
          label: 'Add Profile',
        ),
      ],
      onTap: _onItemTapped,
    );
  }
}