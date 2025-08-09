import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Simple admin login (you can store admin credentials in Firebase or hardcode)
  static Future<bool> adminLogin({
    required String username,
    required String password,
  }) async {
    // Simple hardcoded admin credentials (you can store in Firebase)
    if (username == 'admin' && password == 'admin123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_admin_logged_in', true);
      await prefs.setInt('admin_login_time', DateTime.now().millisecondsSinceEpoch);
      return true;
    }
    return false;
  }

  // Check if admin is logged in
  static Future<bool> isAdminLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_admin_logged_in') ?? false;
  }

  // Admin logout
  static Future<void> adminLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_admin_logged_in', false);
    await prefs.remove('admin_login_time');
  }
}
