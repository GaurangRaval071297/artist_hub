import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  // Private variables
  bool _isLoggedIn = false;
  String _userType = '';
  String _userId = '';
  String _userEmail = '';
  String _userName = '';
  String _userPhone = '';
  String _userAddress = '';
  String _profilePic = '';

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get userType => _userType;
  String get userId => _userId;
  String get userEmail => _userEmail;
  String get userName => _userName;
  String get userPhone => _userPhone;
  String get userAddress => _userAddress;
  String get profilePic => _profilePic;

  // Login method
  void login({
    required String userId,
    required String userType,
    required String userEmail,
    required String userName,
    String userPhone = '',
    String userAddress = '',
    String profilePic = '',
  }) {
    _isLoggedIn = true;
    _userId = userId;
    _userType = userType;
    _userEmail = userEmail;
    _userName = userName;
    _userPhone = userPhone;
    _userAddress = userAddress;
    _profilePic = profilePic;
    notifyListeners();
  }

  // Logout method
  void logout() {
    _isLoggedIn = false;
    _userId = '';
    _userType = '';
    _userEmail = '';
    _userName = '';
    _userPhone = '';
    _userAddress = '';
    _profilePic = '';
    notifyListeners();
  }

  // Update profile
  void updateProfile({
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userAddress,
    String? profilePic,
  }) {
    if (userName != null) _userName = userName;
    if (userEmail != null) _userEmail = userEmail;
    if (userPhone != null) _userPhone = userPhone;
    if (userAddress != null) _userAddress = userAddress;
    if (profilePic != null) _profilePic = profilePic;
    notifyListeners();
  }

  // Set user ID (for cases where we get it later)
  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }
}