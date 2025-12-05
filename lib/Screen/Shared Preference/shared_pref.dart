
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static SharedPreferences? _prefs;

  // Initialize once in main()
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save String
  static Future saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  // Get String
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  // Save Bool
  static Future saveBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  // Get Bool
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // Remove Key
  static Future remove(String key) async {
    await _prefs?.remove(key);
  }

  // Clear All
  static Future clearAll() async {
    await _prefs?.clear();
  }
}
