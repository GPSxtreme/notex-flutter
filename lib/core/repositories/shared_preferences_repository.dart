import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesRepository {
  static const String _jwtKey = 'jwt_token';

  // Method to save the JWT token to shared preferences
  static Future<void> saveJwtToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_jwtKey, token);
  }

  // Method to retrieve the JWT token from shared preferences
  static Future<String?> getJwtToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_jwtKey);
  }

  // Method to remove the JWT token from shared preferences
  static Future<void> removeJwtToken() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_jwtKey);
  }
}
