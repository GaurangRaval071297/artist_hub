import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userIdKey = 'userId';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _userRoleKey = 'userRole';
  static const String _userTokenKey = 'userToken';
  static const String _userProfilePicKey = 'userProfilePic';
  static const String _userPhoneKey = 'userPhone';
  static const String _userAddressKey = 'userAddress';
  static const String _rememberMeKey = 'rememberMe';

  static SharedPreferences? _preferences;
  static bool _isInitialized = false;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  // Helper method to get preferences with null check
  static SharedPreferences _getPrefs() {
    if (!_isInitialized || _preferences == null) {
      throw Exception('SharedPreferences not initialized. Call init() first.');
    }
    return _preferences!;
  }

  // =============== Getter to check if initialized ===============
  static bool get isInitialized => _isInitialized;

  // =============== Login Status ===============
  static Future<void> setLoggedIn(bool value) async {
    await _getPrefs().setBool(_isLoggedInKey, value);
  }

  static bool isLoggedIn() {
    try {
      return _getPrefs().getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // =============== User ID ===============
  static Future<void> setUserId(String userId) async {
    await _getPrefs().setString(_userIdKey, userId);
  }

  static String getUserId() {
    try {
      return _getPrefs().getString(_userIdKey) ?? '';
    } catch (e) {
      print('Error getting user ID: $e');
      return '';
    }
  }

  // =============== User Name ===============
  static Future<void> setUserName(String userName) async {
    await _getPrefs().setString(_userNameKey, userName);
  }

  static String getUserName() {
    try {
      return _getPrefs().getString(_userNameKey) ?? '';
    } catch (e) {
      print('Error getting user name: $e');
      return '';
    }
  }

  // =============== User Email ===============
  static Future<void> setUserEmail(String userEmail) async {
    await _getPrefs().setString(_userEmailKey, userEmail);
  }

  static String getUserEmail() {
    try {
      return _getPrefs().getString(_userEmailKey) ?? '';
    } catch (e) {
      print('Error getting user email: $e');
      return '';
    }
  }

  // =============== User Role ===============
  static Future<void> setUserRole(String userRole) async {
    await _getPrefs().setString(_userRoleKey, userRole);
  }

  static String getUserRole() {
    try {
      return _getPrefs().getString(_userRoleKey) ?? 'customer';
    } catch (e) {
      print('Error getting user role: $e');
      return 'customer';
    }
  }

  // =============== User Token ===============
  static Future<void> setUserToken(String token) async {
    await _getPrefs().setString(_userTokenKey, token);
  }

  static String getUserToken() {
    try {
      return _getPrefs().getString(_userTokenKey) ?? '';
    } catch (e) {
      print('Error getting user token: $e');
      return '';
    }
  }

  // =============== User Profile Pic ===============
  static Future<void> setUserProfilePic(String profilePic) async {
    await _getPrefs().setString(_userProfilePicKey, profilePic);
  }

  static String getUserProfilePic() {
    try {
      return _getPrefs().getString(_userProfilePicKey) ?? '';
    } catch (e) {
      print('Error getting user profile pic: $e');
      return '';
    }
  }

  // =============== User Phone ===============
  static Future<void> setUserPhone(String phone) async {
    await _getPrefs().setString(_userPhoneKey, phone);
  }

  static String getUserPhone() {
    try {
      return _getPrefs().getString(_userPhoneKey) ?? '';
    } catch (e) {
      print('Error getting user phone: $e');
      return '';
    }
  }

  // =============== User Address ===============
  static Future<void> setUserAddress(String address) async {
    await _getPrefs().setString(_userAddressKey, address);
  }

  static String getUserAddress() {
    try {
      return _getPrefs().getString(_userAddressKey) ?? '';
    } catch (e) {
      print('Error getting user address: $e');
      return '';
    }
  }

  // =============== Remember Me ===============
  static Future<void> setRememberMe(bool value) async {
    await _getPrefs().setBool(_rememberMeKey, value);
  }

  static bool getRememberMe() {
    try {
      return _getPrefs().getBool(_rememberMeKey) ?? false;
    } catch (e) {
      print('Error getting remember me: $e');
      return false;
    }
  }

  // =============== Save All User Data ===============
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      if (userData['id'] != null) {
        await setUserId(userData['id'].toString());
      }
      if (userData['name'] != null) {
        await setUserName(userData['name'].toString());
      }
      if (userData['email'] != null) {
        await setUserEmail(userData['email'].toString());
      }
      if (userData['role'] != null) {
        await setUserRole(userData['role'].toString().toLowerCase());
      }
      if (userData['token'] != null) {
        await setUserToken(userData['token'].toString());
      }
      if (userData['profile_pic'] != null || userData['profilePic'] != null) {
        await setUserProfilePic(
            userData['profile_pic']?.toString() ??
                userData['profilePic']?.toString() ?? ''
        );
      }
      if (userData['phone'] != null) {
        await setUserPhone(userData['phone'].toString());
      }
      if (userData['address'] != null) {
        await setUserAddress(userData['address'].toString());
      }

      await setLoggedIn(true);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // =============== Get All User Data ===============
  static Map<String, dynamic> getUserData() {
    try {
      return {
        'id': getUserId(),
        'name': getUserName(),
        'email': getUserEmail(),
        'role': getUserRole(),
        'token': getUserToken(),
        'profile_pic': getUserProfilePic(),
        'phone': getUserPhone(),
        'address': getUserAddress(),
        'isLoggedIn': isLoggedIn(),
      };
    } catch (e) {
      print('Error getting user data: $e');
      return {};
    }
  }

  // =============== LOGOUT METHODS ===============

  // Method 1: Clear all data completely
  static Future<void> clearAllData() async {
    try {
      await _getPrefs().clear();
      _isInitialized = false;
      _preferences = null;
      print('All user data cleared from SharedPreferences');
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  // Method 2: Clear only login-related data (preserves settings)
  static Future<void> logout() async {
    try {
      // Clear only authentication-related data
      await _getPrefs().remove(_isLoggedInKey);
      await _getPrefs().remove(_userIdKey);
      await _getPrefs().remove(_userNameKey);
      await _getPrefs().remove(_userEmailKey);
      await _getPrefs().remove(_userRoleKey);
      await _getPrefs().remove(_userTokenKey);
      await _getPrefs().remove(_userProfilePicKey);
      await _getPrefs().remove(_userPhoneKey);
      await _getPrefs().remove(_userAddressKey);

      // Optionally clear remember me
      await _getPrefs().remove(_rememberMeKey);

      print('User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Method 3: Logout but keep remember me email
  static Future<void> logoutKeepEmail() async {
    try {
      String savedEmail = getUserEmail();
      bool rememberMe = getRememberMe();

      // Clear all data first
      await clearAllData();

      // Restore email if remember me was enabled
      if (rememberMe && savedEmail.isNotEmpty) {
        await _getPrefs().setString(_userEmailKey, savedEmail);
        await _getPrefs().setBool(_rememberMeKey, true);
      }

      print('Logged out - email preserved: $rememberMe');
    } catch (e) {
      print('Error during logout with email preservation: $e');
    }
  }

  // Method 4: Check if user can auto-login
  static bool canAutoLogin() {
    try {
      return isLoggedIn() && getUserId().isNotEmpty;
    } catch (e) {
      print('Error checking auto login: $e');
      return false;
    }
  }

  // =============== Check Specific Values ===============
  static bool hasData() {
    try {
      return getUserId().isNotEmpty;
    } catch (e) {
      print('Error checking data: $e');
      return false;
    }
  }

  // =============== Debug Methods ===============
  static void printAllData() {
    try {
      print('=== SharedPreferences Data ===');
      print('isLoggedIn: ${isLoggedIn()}');
      print('userId: ${getUserId()}');
      print('userName: ${getUserName()}');
      print('userEmail: ${getUserEmail()}');
      print('userRole: ${getUserRole()}');
      print('hasToken: ${getUserToken().isNotEmpty}');
      print('hasProfilePic: ${getUserProfilePic().isNotEmpty}');
      print('rememberMe: ${getRememberMe()}');
      print('=============================');
    } catch (e) {
      print('Error printing data: $e');
    }
  }
}