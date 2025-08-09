import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthService {
  // Simple hardcoded admin credentials (you can modify these)
  static const String ADMIN_USERNAME = 'admin';
  static const String ADMIN_PASSWORD = 'admin123';

  // Session duration (optional - you can remove this for permanent login)
  static const int SESSION_HOURS = 24; // 24 hours session

  // Simple admin login with hardcoded credentials
  static Future<bool> adminLogin({
    required String username,
    required String password,
  }) async {
    // Check credentials locally
    if (username == ADMIN_USERNAME && password == ADMIN_PASSWORD) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_admin_logged_in', true);
      await prefs.setInt('admin_login_time', DateTime.now().millisecondsSinceEpoch);
      return true;
    }
    return false;
  }

  // Check if admin is logged in
  static Future<bool> isAdminLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_admin_logged_in') ?? false;

      if (!isLoggedIn) return false;

      // Optional: Check session expiration
      final loginTime = prefs.getInt('admin_login_time') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final sessionDuration = Duration(hours: SESSION_HOURS).inMilliseconds;

      // If session expired, auto-logout
      if (currentTime - loginTime > sessionDuration) {
        await adminLogout();
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking admin login: $e');
      return false;
    }
  }

  // Admin logout
  static Future<void> adminLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_admin_logged_in', false);
      await prefs.remove('admin_login_time');
    } catch (e) {
      print('Error during admin logout: $e');
    }
  }

  // Optional: Extend session (call this when admin is active)
  static Future<void> extendSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_admin_logged_in') ?? false;

      if (isLoggedIn) {
        await prefs.setInt('admin_login_time', DateTime.now().millisecondsSinceEpoch);
      }
    } catch (e) {
      print('Error extending session: $e');
    }
  }
}
