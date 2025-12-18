import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Intro Screen
  static bool get isFirstTime => _preferences.getBool('isFirstTime') ?? true;
  static Future<void> setFirstTime(bool value) async {
    await _preferences.setBool('isFirstTime', value);
  }

  // User Auth
  static Future<void> setUserLoggedIn(bool value) async {
    await _preferences.setBool('isLoggedIn', value);
  }

  static bool get isUserLoggedIn => _preferences.getBool('isLoggedIn') ?? false;

  static Future<void> setUserEmail(String email) async {
    await _preferences.setString('userEmail', email);
  }

  static String get userEmail => _preferences.getString('userEmail') ?? '';

  static Future<void> setUserName(String name) async {
    await _preferences.setString('userName', name);
  }

  static String get userName => _preferences.getString('userName') ?? '';

  static Future<void> setUserType(String type) async {
    await _preferences.setString('userType', type);
  }

  static String get userType => _preferences.getString('userType') ?? '';

  static Future<void> clearUserData() async {
    await _preferences.remove('isLoggedIn');
    await _preferences.remove('userEmail');
    await _preferences.remove('userName');
    await _preferences.remove('userType');
  }

  // Add these methods to your SharedPreferencesHelper class

  static Future<void> setUserProfilePic(String profilePicUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile_pic', profilePicUrl);
  }

  static Future<String?> getUserProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_profile_pic');
  }
}