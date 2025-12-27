import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _prefs;

  static const String _isFirstTimeKey = 'isFirstTime';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userEmailKey = 'userEmail';
  static const String _userTypeKey = 'userType';
  static const String _userIdKey = 'userId';
  static const String _userNameKey = 'userName';
  static const String _userProfilePicKey = 'userProfilePic';
  static const String _userPhoneKey = 'userPhone';
  static const String _userAddressKey = 'userAddress';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isFirstTime {
    return _prefs?.getBool(_isFirstTimeKey) ?? true;
  }

  static Future<void> setFirstTime(bool value) async {
    await _prefs?.setBool(_isFirstTimeKey, value);
  }

  static bool get isUserLoggedIn {
    return _prefs?.getBool(_isLoggedInKey) ?? false;
  }

  static String get userPhone {
    return _prefs?.getString(_userPhoneKey) ?? '';
  }

  static Future<void> setUserPhone(String phone) async {
    await _prefs?.setString(_userPhoneKey, phone);
  }
  static Future<void> setUserLoggedIn(bool value) async {
    await _prefs?.setBool(_isLoggedInKey, value);
  }

  static String get userEmail {
    return _prefs?.getString(_userEmailKey) ?? '';
  }

  static Future<void> setUserEmail(String email) async {
    await _prefs?.setString(_userEmailKey, email);
  }

  static String get userType {
    return _prefs?.getString(_userTypeKey) ?? '';
  }

  static Future<void> setUserType(String type) async {
    await _prefs?.setString(_userTypeKey, type);
  }

  static String get userId {
    return _prefs?.getString(_userIdKey) ?? '';
  }

  static Future<void> setUserId(String id) async {
    await _prefs?.setString(_userIdKey, id);
  }

  static String get userName {
    return _prefs?.getString(_userNameKey) ?? '';
  }

  static Future<void> setUserName(String name) async {
    await _prefs?.setString(_userNameKey, name);
  }

  static String get userProfilePic {
    return _prefs?.getString(_userProfilePicKey) ?? '';
  }

  static Future<void> setUserProfilePic(String url) async {
    await _prefs?.setString(_userProfilePicKey, url);
  }


  static String get userAddress {
    return _prefs?.getString(_userAddressKey) ?? '';
  }

  static Future<void> setUserAddress(String address) async {
    await _prefs?.setString(_userAddressKey, address);
  }

  static Future<void> clearAll() async {
    await _prefs?.remove(_isLoggedInKey);
    await _prefs?.remove(_userEmailKey);
    await _prefs?.remove(_userTypeKey);
    await _prefs?.remove(_userIdKey);
    await _prefs?.remove(_userNameKey);
    await _prefs?.remove(_userProfilePicKey);
    await _prefs?.remove(_userPhoneKey);
    await _prefs?.remove(_userAddressKey);
  }
}
