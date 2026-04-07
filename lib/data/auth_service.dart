import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  // ✅ Save user basic auth
  static Future<void> registerUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("email", email);
    await prefs.setString("password", password);
  }

  // ✅ Login check
  static Future<bool> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    return email == prefs.getString("email") &&
        password == prefs.getString("password");
  }

  // ✅ Save profile
  static Future<void> saveProfile({
    required String name,
    required String gender,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("name", name);
    await prefs.setString("gender", gender);
    if (imagePath != null) {
      await prefs.setString("image", imagePath);
    }

    await prefs.setBool("profileComplete", true);
  }

  // ✅ Get profile
  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "name": prefs.getString("name") ?? "Guest",
      "gender": prefs.getString("gender") ?? "",
      "image": prefs.getString("image") ?? "",
    };
  }

  // ✅ Check profile complete
  static Future<bool> isProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("profileComplete") ?? false;
  }

  // ✅ Login session
  static Future<void> setLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLoggedIn") ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}