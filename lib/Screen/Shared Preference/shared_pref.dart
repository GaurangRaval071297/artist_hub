import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static late SharedPreferences _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ================ SETTERS ================

  // Save user ID
  static Future<bool> setUserId(String userId) async {
    return await _prefs.setString('userId', userId);
  }

  // Save user email
  static Future<bool> setUserEmail(String email) async {
    return await _prefs.setString('userEmail', email);
  }

  // Save user name
  static Future<bool> setUserName(String name) async {
    return await _prefs.setString('userName', name);
  }

  // Save token (for authentication)
  static Future<bool> setToken(String token) async {
    return await _prefs.setString('token', token);
  }

  // Save login status
  static Future<bool> setLoginStatus(bool isLoggedIn) async {
    return await _prefs.setBool('isLoggedIn', isLoggedIn);
  }

  // Save user data as JSON string
  static Future<bool> setUserData(String userData) async {
    return await _prefs.setString('userData', userData);
  }

  // Save any custom value
  static Future<bool> setValue(String key, dynamic value) async {
    if (value is String) {
      return await _prefs.setString(key, value);
    } else if (value is int) {
      return await _prefs.setInt(key, value);
    } else if (value is double) {
      return await _prefs.setDouble(key, value);
    } else if (value is bool) {
      return await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      return await _prefs.setStringList(key, value);
    } else {
      return false;
    }
  }

  // ================ GETTERS ================

  // Get user ID
  static String? getUserId() {
    return _prefs.getString('userId');
  }

  // Get user email
  static String? getUserEmail() {
    return _prefs.getString('userEmail');
  }

  // Get user name
  static String? getUserName() {
    return _prefs.getString('userName');
  }

  // Get token
  static String? getToken() {
    return _prefs.getString('token');
  }

  // Get login status
  static bool getLoginStatus() {
    return _prefs.getBool('isLoggedIn') ?? false;
  }

  // Get user data
  static String? getUserData() {
    return _prefs.getString('userData');
  }

  // Get any value
  static dynamic getValue(String key) {
    return _prefs.get(key);
  }

  // ================ REMOVE/CLEAR ================

  // Remove specific key
  static Future<bool> removeKey(String key) async {
    return await _prefs.remove(key);
  }

  // Clear all data (logout)
  static Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  // Clear only user data but keep settings
  static Future<void> clearUserData() async {
    await _prefs.remove('userId');
    await _prefs.remove('userEmail');
    await _prefs.remove('userName');
    await _prefs.remove('token');
    await _prefs.remove('isLoggedIn');
    await _prefs.remove('userData');
  }

  // ================ CHECKERS ================

  // Check if user is logged in
  static bool isUserLoggedIn() {
    return getLoginStatus() && getToken() != null;
  }

  // Check if key exists
  static bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}