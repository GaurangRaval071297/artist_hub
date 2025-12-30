import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:artist_hub/shared/constants/app_colors.dart';
import 'package:artist_hub/shared/constants/custom_dialog.dart';
import 'package:artist_hub/shared/preferences/shared_preferences.dart';

class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({super.key});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  bool _isLoading = false;
  bool _isUpdating = false;

  // Controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  String? _userId;

  @override
  void initState() {
    super.initState();

    // Get userId first
    _userId = SharedPreferencesHelper.userId;

    // Initialize controllers with current data
    _nameController = TextEditingController(
      text: SharedPreferencesHelper.userName,
    );
    _emailController = TextEditingController(
      text: SharedPreferencesHelper.userEmail,
    );
    _phoneController = TextEditingController(
      text: SharedPreferencesHelper.userPhone,
    );
    _addressController = TextEditingController(
      text: SharedPreferencesHelper.userAddress,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ============== UPDATE USER API CALL ==============
  Future<void> _updateUserProfile({
    required String fieldName, // 'name', 'email', 'phone', 'address'
    required String newValue,
  }) async {
    // Validate userId
    if (_userId == null || _userId!.isEmpty) {
      _showAlert('Error', 'User ID not found. Please login again.');
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final url = Uri.parse('https://prakrutitech.xyz/gaurang/update_user.php');

      // Prepare request body according to API requirements
      Map<String, String> requestBody = {
        'id': _userId!, // API expects 'id' not 'user_id'
      };

      // Add the field to update based on fieldName
      if (fieldName == 'name') {
        requestBody['name'] = newValue;
      } else if (fieldName == 'email') {
        requestBody['email'] = newValue;
      } else if (fieldName == 'phone') {
        requestBody['phone'] = newValue;
      } else if (fieldName == 'address') {
        requestBody['address'] = newValue;
      }

      final response = await http.post(url, body: requestBody);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          // Update SharedPreferences
          switch (fieldName) {
            case 'name':
              await SharedPreferencesHelper.setUserName(newValue);
              _nameController.text = newValue;
              break;
            case 'email':
              await SharedPreferencesHelper.setUserEmail(newValue);
              _emailController.text = newValue;
              break;
            case 'phone':
              await SharedPreferencesHelper.setUserPhone(newValue);
              _phoneController.text = newValue;
              break;
            case 'address':
              await SharedPreferencesHelper.setUserAddress(newValue);
              _addressController.text = newValue;
              break;
          }

          _showAlert(
            'Success',
            data['message'] ?? 'Profile updated successfully!',
            isSuccess: true,
          );
        } else {
          _showAlert('Error', data['message'] ?? 'Update failed');
        }
      } else {
        _showAlert('Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Update Error: $e');
      _showAlert('Error', 'Network error: $e');
    } finally {
      setState(() => _isUpdating = false);
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

  // ============== EDIT FIELD DIALOG ==============
  void _showEditDialog({
    required String fieldName,
    required String fieldTitle,
    required String currentValue,
    required String hint,
    required TextInputType keyboardType,
  }) {
    TextEditingController editController = TextEditingController(
      text: currentValue,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $fieldTitle'),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          keyboardType: keyboardType,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newValue = editController.text.trim();
              if (newValue.isNotEmpty && newValue != currentValue) {
                Navigator.pop(context);
                await _updateUserProfile(
                  fieldName: fieldName,
                  newValue: newValue,
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get data from SharedPreferences
    final userName = SharedPreferencesHelper.userName;
    final userEmail = SharedPreferencesHelper.userEmail;
    final userPhone = SharedPreferencesHelper.userPhone;
    final userAddress = SharedPreferencesHelper.userAddress;
    final userType = SharedPreferencesHelper.userType;
    final userId = SharedPreferencesHelper.userId;

    // Check if userId is valid
    final bool hasValidUserId = userId != null && userId.isNotEmpty;

    // Profile items list
    final List<Map<String, dynamic>> profileItems = [
      {
        'icon': Icons.person,
        'title': 'Name',
        'value': userName,
        'fieldName': 'name',
        'fieldTitle': 'Name',
        'hint': 'Enter your name',
        'keyboard': TextInputType.name,
        'editable': true,
      },
      {
        'icon': Icons.email,
        'title': 'Email',
        'value': userEmail,
        'fieldName': 'email',
        'fieldTitle': 'Email',
        'hint': 'Enter your email',
        'keyboard': TextInputType.emailAddress,
        'editable': true,
      },
      {
        'icon': Icons.phone,
        'title': 'Phone',
        'value': userPhone,
        'fieldName': 'phone',
        'fieldTitle': 'Phone',
        'hint': 'Enter 10-digit phone',
        'keyboard': TextInputType.phone,
        'editable': true,
      },
      {
        'icon': Icons.location_on,
        'title': 'Address',
        'value': userAddress,
        'fieldName': 'address',
        'fieldTitle': 'Address',
        'hint': 'Enter your address',
        'keyboard': TextInputType.streetAddress,
        'editable': true,
      },
      {
        'icon': Icons.work,
        'title': 'Role',
        'value': userType,
        'fieldName': 'role',
        'fieldTitle': 'Role',
        'hint': '',
        'keyboard': TextInputType.text,
        'editable': false,
      },
      {
        'icon': Icons.badge,
        'title': 'User ID',
        'value': hasValidUserId ? userId : 'Not available',
        'fieldName': 'id',
        'fieldTitle': 'User ID',
        'hint': '',
        'keyboard': TextInputType.text,
        'editable': false,
      },
    ];

    // Show warning if userId is missing
    Widget? userIdWarning;
    if (!hasValidUserId) {
      userIdWarning = Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[800]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'User ID not found. Profile updates may not work.',
                style: TextStyle(color: Colors.orange[800]),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // User ID warning (if any)
                if (userIdWarning != null) userIdWarning,

                // Profile Header
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.appBarGradient.colors[0]
                              .withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.appBarGradient.colors[0],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Chip(
                          label: Text(
                            userType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: userType == 'artist'
                              ? Colors.deepPurple
                              : Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              userAddress.isNotEmpty
                                  ? userAddress
                                  : 'Address not set',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        // Show user ID in header if available
                        if (hasValidUserId)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'ID: $userId',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Profile Details List with Edit buttons
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Profile Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.edit_note, color: Colors.blue),
                          ],
                        ),
                      ),
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: profileItems.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.grey[200]),
                        itemBuilder: (context, index) {
                          final item = profileItems[index];
                          final value = item['value'] as String;
                          final fieldName = item['fieldName'] as String;
                          final fieldTitle = item['fieldTitle'] as String;
                          final isEditable =
                              item['editable'] as bool && hasValidUserId;

                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.appBarGradient.colors[0]
                                    .withOpacity(0.1),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: AppColors.appBarGradient.colors[0],
                                size: 20,
                              ),
                            ),
                            title: Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            subtitle: Text(
                              value.isNotEmpty ? value : 'Not provided',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: isEditable
                                ? IconButton(
                                    icon: _isUpdating
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Colors.blue,
                                          ),
                                    onPressed: _isUpdating
                                        ? null
                                        : () {
                                            _showEditDialog(
                                              fieldName: fieldName,
                                              fieldTitle: fieldTitle,
                                              currentValue: value,
                                              hint: item['hint'] as String,
                                              keyboardType:
                                                  item['keyboard']
                                                      as TextInputType,
                                            );
                                          },
                                  )
                                : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Update All Button (only show if userId is valid)
                if (hasValidUserId)
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Update',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Update all fields at once:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _isUpdating
                                  ? null
                                  : () async {
                                      // Update all fields
                                      final updates = <Map<String, String>>[];

                                      if (_nameController.text.isNotEmpty &&
                                          _nameController.text != userName) {
                                        updates.add({
                                          'fieldName': 'name',
                                          'newValue': _nameController.text,
                                        });
                                      }
                                      if (_emailController.text.isNotEmpty &&
                                          _emailController.text != userEmail) {
                                        updates.add({
                                          'fieldName': 'email',
                                          'newValue': _emailController.text,
                                        });
                                      }
                                      if (_phoneController.text.isNotEmpty &&
                                          _phoneController.text != userPhone) {
                                        updates.add({
                                          'fieldName': 'phone',
                                          'newValue': _phoneController.text,
                                        });
                                      }
                                      if (_addressController.text.isNotEmpty &&
                                          _addressController.text !=
                                              userAddress) {
                                        updates.add({
                                          'fieldName': 'address',
                                          'newValue': _addressController.text,
                                        });
                                      }

                                      if (updates.isNotEmpty) {
                                        for (final update in updates) {
                                          await _updateUserProfile(
                                            fieldName: update['fieldName']!,
                                            newValue: update['newValue']!,
                                          );
                                        }
                                      } else {
                                        _showAlert(
                                          'Info',
                                          'No changes to update',
                                        );
                                      }
                                    },
                              icon: _isUpdating
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.update),
                              label: _isUpdating
                                  ? const Text('Updating...')
                                  : const Text('Update All'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
    );
  }
}
