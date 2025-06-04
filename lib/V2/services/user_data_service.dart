import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage persistent user data across the app
class UserDataService {
  // Keys for SharedPreferences
  static const String _userCiKey = 'user_ci';
  static const String _userAdminKey = 'user_admin';

  /// Store the user's CI (ID) in local storage
  static Future<bool> saveUserCi(String ci) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userCiKey, ci);
      print('✅ User CI saved: $ci');
      return true;
    } catch (e) {
      print('❌ Error saving user CI: $e');
      return false;
    }
  }

  /// Get the user's CI (ID) from local storage
  static Future<String?> getUserCi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ci = prefs.getString(_userCiKey);
      print('📱 Retrieved user CI: $ci');
      return ci;
    } catch (e) {
      print('❌ Error retrieving user CI: $e');
      return null;
    }
  }

  /// Store the user's admin status in local storage
  static Future<bool> saveUserAdminStatus(bool isAdmin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_userAdminKey, isAdmin);
      print('✅ User admin status saved: $isAdmin');
      return true;
    } catch (e) {
      print('❌ Error saving user admin status: $e');
      return false;
    }
  }

  /// Get the user's admin status from local storage
  static Future<bool> getUserAdminStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAdmin = prefs.getBool(_userAdminKey) ?? false;
      print('📱 Retrieved user admin status: $isAdmin');
      return isAdmin;
    } catch (e) {
      print('❌ Error retrieving user admin status: $e');
      return false;
    }
  }

  /// Clear all user data (logout)
  static Future<bool> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('🧹 User data cleared');
      return true;
    } catch (e) {
      print('❌ Error clearing user data: $e');
      return false;
    }
  }
} 