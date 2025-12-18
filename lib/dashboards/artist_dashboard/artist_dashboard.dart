import 'package:artist_hub/shared/Constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:artist_hub/auth/login_screen.dart';
import 'package:artist_hub/shared/preferences/shared_preferences.dart';
import 'package:artist_hub/shared/widgets/common_appbar/Common_Appbar.dart';

class ArtistDashboard extends StatefulWidget {
  const ArtistDashboard({super.key});

  @override
  State<ArtistDashboard> createState() => _ArtistDashboardState();
}

class _ArtistDashboardState extends State<ArtistDashboard> {
  String userName = 'Artist';
  String userEmail = '';
  String? userImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    await SharedPreferencesHelper.init();
    setState(() {
      userName = SharedPreferencesHelper.userName.isNotEmpty
          ? SharedPreferencesHelper.userName
          : 'Artist';
      userEmail = SharedPreferencesHelper.userEmail;
    });
  }

  Future<void> _logout() async {
    await SharedPreferencesHelper.clearUserData();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CommonAppbar(
        title: 'Artist Dashboard',
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.appBarGradient.colors[0].withOpacity(0.95),
                    AppColors.appBarGradient.colors[1].withOpacity(0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // Profile Image
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.9),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          userEmail.isNotEmpty ? userEmail : 'artist@example.com',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Professional Artist',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit Profile Button
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to Edit Profile screen
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white.withOpacity(0.9),
                      size: 22,
                    ),
                    tooltip: 'Edit Profile',
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 10),
                children: [
                  // Dashboard Section
                  _buildSectionTitle('Dashboard'),
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: 'Overview',
                    onTap: () {
                      Navigator.pop(context);
                      // Already on dashboard
                    },
                    isSelected: true,
                  ),
                  _buildDrawerItem(
                    icon: Icons.bar_chart,
                    title: 'Analytics',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Analytics
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.trending_up,
                    title: 'Performance',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Performance
                    },
                  ),

                  const Divider(height: 30, thickness: 1),

                  // Portfolio Section
                  _buildSectionTitle('Portfolio'),
                  _buildDrawerItem(
                    icon: Icons.photo_library,
                    title: 'My Portfolio',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Portfolio
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.add_a_photo,
                    title: 'Add New Work',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Add Work
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.category,
                    title: 'Categories',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Categories
                    },
                  ),

                  const Divider(height: 30, thickness: 1),

                  // Bookings Section
                  _buildSectionTitle('Bookings'),
                  _buildDrawerItem(
                    icon: Icons.calendar_today,
                    title: 'My Bookings',
                    badgeCount: 5,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Bookings
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.schedule,
                    title: 'Availability',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Availability
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.star_border,
                    title: 'Reviews',
                    badgeCount: 12,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Reviews
                    },
                  ),

                  const Divider(height: 30, thickness: 1),

                  // Settings Section
                  _buildSectionTitle('Settings'),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Settings
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    badgeCount: 3,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Notifications
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Help
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Privacy Policy
                    },
                  ),
                ],
              ),
            ),

            // Logout Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Logout Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error.withOpacity(0.9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Welcome to Artist Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        top: 20,
        bottom: 10,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    int badgeCount = 0,
    bool isSelected = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        )
            : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade800,
          ),
        ),
        trailing: badgeCount > 0
            ? Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            badgeCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        dense: true,
      ),
    );
  }
}