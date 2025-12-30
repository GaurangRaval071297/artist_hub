import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:artist_hub/shared/constants/app_colors.dart';
import 'package:artist_hub/shared/constants/custom_dialog.dart';
import 'package:artist_hub/shared/preferences/shared_preferences.dart';

class ArtistProfile {
  final String? id;
  final String userId;
  final String category;
  final String experience;
  final String price;
  final String description;
  final String artistName;
  final String artistEmail;
  final String? location;
  final String? skills;

  ArtistProfile({
    this.id,
    required this.userId,
    required this.category,
    required this.experience,
    required this.price,
    required this.description,
    required this.artistName,
    required this.artistEmail,
    this.location,
    this.skills,
  });

  factory ArtistProfile.fromJson(Map<String, dynamic> json) {
    return ArtistProfile(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      experience: json['experience']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      artistName: json['artist_name']?.toString() ?? '',
      artistEmail: json['artist_email']?.toString() ?? '',
      location: json['location']?.toString(),
      skills: json['skills']?.toString(),
    );
  }
}

class AddArtistProfile extends StatefulWidget {
  const AddArtistProfile({super.key});

  @override
  State<AddArtistProfile> createState() => _AddArtistProfileState();
}

class _AddArtistProfileState extends State<AddArtistProfile> {
  bool _isLoading = true;
  bool _isCreating = false;
  List<ArtistProfile> _myProfiles = [];
  ArtistProfile? _currentProfile;
  int _currentProfileIndex = 0;

  final List<String> _categories = [
    'Painter',
    'Digital Artist',
    'Sculptor',
    'Photographer',
    'Musician',
    'Dancer',
    'Singer',
    'Actor',
    'Writer',
    'Designer',
    'Photography',
    'Music',
    'Dance'
  ];

  // Form controllers
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMyArtistProfile();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _experienceController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ================= FETCH PROFILE =================
  Future<void> _fetchMyArtistProfile() async {
    setState(() => _isLoading = true);

    try {
      final userId = SharedPreferencesHelper.userId;
      if (userId.isEmpty) {
        _showAlert('Error', 'Please login first.', isSuccess: false);
        setState(() => _isLoading = false);
        return;
      }

      final url = Uri.parse('https://prakrutitech.xyz/gaurang/view_artist_profile.php?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _myProfiles.clear();

        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> profilesData = data['data'];

          for (var profileData in profilesData) {
            _myProfiles.add(ArtistProfile.fromJson(profileData));
          }

          // Sort by ID descending (newest first)
          _myProfiles.sort((a, b) {
            final int idA = int.tryParse(a.id ?? '0') ?? 0;
            final int idB = int.tryParse(b.id ?? '0') ?? 0;
            return idB.compareTo(idA);
          });

          if (_myProfiles.isNotEmpty) {
            _currentProfile = _myProfiles.first;
            _currentProfileIndex = 0;

            // Pre-fill form
            _categoryController.text = _currentProfile!.category;
            _experienceController.text = _currentProfile!.experience;
            _priceController.text = _currentProfile!.price;
            _descriptionController.text = _currentProfile!.description;
            _locationController.text = _currentProfile!.location ?? '';
          }
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================= CREATE PROFILE =================
  Future<void> _createArtistProfile() async {
    if (_categoryController.text.isEmpty ||
        _experienceController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      _showAlert('Error', 'Please fill all required fields.', isSuccess: false);
      return;
    }

    setState(() => _isCreating = true);

    try {
      final userId = SharedPreferencesHelper.userId;
      final userName = SharedPreferencesHelper.userName;
      final userEmail = SharedPreferencesHelper.userEmail;

      final url = Uri.parse('https://prakrutitech.xyz/gaurang/add_artist_profile.php');

      final response = await http.post(
        url,
        body: {
          'user_id': userId,
          'artist_name': userName,
          'artist_email': userEmail,
          'category': _categoryController.text.trim(),
          'experience': _experienceController.text.trim(),
          'price': _priceController.text.trim(),
          'description': _descriptionController.text.trim(),
          'location': _locationController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          _showAlert('Success', 'Profile created successfully!', isSuccess: true);
          await _fetchMyArtistProfile();
        } else {
          _showAlert('Error', data['message'] ?? 'Failed to create profile.', isSuccess: false);
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      _showAlert('Error', 'Network error occurred.', isSuccess: false);
    } finally {
      setState(() => _isCreating = false);
    }
  }

  void _showAlert(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (_) => CustomAlertDialog(
        title: title,
        message: message,
        icon: isSuccess ? Icons.check_circle : Icons.error,
        isSuccess: isSuccess,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // ================= PROFILE CARD DESIGN =================
  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Profile Header with Gradient
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.appBarGradient.colors[0],
                    AppColors.appBarGradient.colors[1],
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  // Background Pattern
                  Opacity(
                    opacity: 0.1,
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/pattern.png'),
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                    ),
                  ),

                  // Profile Info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Name
                        Text(
                          _currentProfile!.artistName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentProfile!.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Counter
                  if (_myProfiles.length > 1)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentProfileIndex + 1}/${_myProfiles.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Profile Stats
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.timeline,
                        value: _currentProfile!.experience,
                        label: 'Experience',
                        color: Colors.blue,
                      ),
                      _buildStatItem(
                        icon: Icons.currency_rupee,
                        value: '₹${_currentProfile!.price}/hr',
                        label: 'Price',
                        color: Colors.green,
                      ),
                      _buildStatItem(
                        icon: Icons.star,
                        value: '4.8',
                        label: 'Rating',
                        color: Colors.amber,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Profile Details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Profile Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildDetailRow(
                          icon: Icons.category,
                          label: 'Category',
                          value: _currentProfile!.category,
                        ),
                        _buildDetailRow(
                          icon: Icons.timeline,
                          label: 'Experience',
                          value: _currentProfile!.experience,
                        ),
                        _buildDetailRow(
                          icon: Icons.currency_rupee,
                          label: 'Price',
                          value: '₹${_currentProfile!.price}/hour',
                        ),
                        if (_currentProfile!.location != null && _currentProfile!.location!.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.location_on,
                            label: 'Location',
                            value: _currentProfile!.location!,
                          ),
                        _buildDetailRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: _currentProfile!.artistEmail,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // About Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About Artist',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          _currentProfile!.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showCreateEditForm(),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.appBarGradient.colors[0],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_myProfiles.length > 1)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _switchProfile,
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Switch'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.appBarGradient.colors[0],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(color: AppColors.appBarGradient.colors[0]),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= NO PROFILE DESIGN =================
  Widget _buildNoProfileDesign() {
    final userName = SharedPreferencesHelper.userName;
    final userId = SharedPreferencesHelper.userId;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.appBarGradient.colors[0].withOpacity(0.1),
                    AppColors.appBarGradient.colors[1].withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_alt_1,
                size: 100,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 40),

            // Welcome Text
            Text(
              'Welcome, $userName!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'User ID: $userId',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 50,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'No Artist Profile Found',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 15),

                    const Text(
                      'Create a professional artist profile to showcase your talents, set your pricing, and start receiving booking requests.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isCreating ? null : () => _showCreateEditForm(),
                        icon: _isCreating
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.add_circle_outline),
                        label: _isCreating
                            ? const Text('Creating...')
                            : const Text(
                          'Create Artist Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.appBarGradient.colors[0],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Tips Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        'Profile Tips',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    '• Add your professional experience\n• Set competitive pricing\n• Write an engaging description\n• Add skills and specializations\n• Upload portfolio images',
                    style: TextStyle(
                      color: Colors.blue,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ALL PROFILES LIST =================
  Widget _buildProfilesList() {
    if (_myProfiles.length <= 1) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.list, color: Colors.deepPurple),
                  SizedBox(width: 10),
                  Text(
                    'All Profiles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ..._myProfiles.map((profile) {
                final isCurrent = profile.id == _currentProfile!.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isCurrent ? Colors.deepPurple.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isCurrent ? Border.all(color: Colors.deepPurple) : null,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrent ? Colors.deepPurple : Colors.grey[300],
                      child: Text(
                        profile.category[0],
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      profile.category,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '₹${profile.price}/hr • ${profile.experience}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: isCurrent
                        ? const Chip(
                      label: Text('Active', style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white),
                    )
                        : IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: () => _switchToProfile(profile),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPER METHODS =================
  void _switchProfile() {
    if (_myProfiles.isEmpty) return;

    setState(() {
      _currentProfileIndex = (_currentProfileIndex + 1) % _myProfiles.length;
      _currentProfile = _myProfiles[_currentProfileIndex];
    });
  }

  void _switchToProfile(ArtistProfile profile) {
    final index = _myProfiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      setState(() {
        _currentProfileIndex = index;
        _currentProfile = profile;
      });
    }
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Icon(icon, size: 30, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= CREATE/EDIT FORM =================
  void _showCreateEditForm() {
    final isEdit = _currentProfile != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Draggable Handle
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit Profile' : 'Create Profile',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Form
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Category
                      DropdownButtonFormField<String>(
                        value: _categoryController.text.isNotEmpty ? _categoryController.text : null,
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _categoryController.text = value!;
                        },
                        decoration: InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Experience
                      TextFormField(
                        controller: _experienceController,
                        decoration: InputDecoration(
                          labelText: 'Experience *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Price
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price per hour (₹) *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isCreating
                                  ? null
                                  : () async {
                                await _createArtistProfile();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.appBarGradient.colors[0],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isCreating
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Text(isEdit ? 'Update' : 'Create'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _myProfiles.isEmpty ? 'Create Profile' : 'Artist Profile',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.appBarGradient.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMyArtistProfile,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.appBarGradient.colors[0],
            ),
            const SizedBox(height: 15),
            const Text(
              'Loading profile...',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : _myProfiles.isEmpty
          ? _buildNoProfileDesign()
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileCard(),
                  _buildProfilesList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _myProfiles.isNotEmpty
          ? FloatingActionButton(
        onPressed: () => _showCreateEditForm(),
        backgroundColor: AppColors.appBarGradient.colors[0],
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}