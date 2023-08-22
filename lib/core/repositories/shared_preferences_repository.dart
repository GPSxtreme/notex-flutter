import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesRepository {
  static const String _jwtKey = 'jwt_token';
  static const String _enableAutoSync = 'enableAutoSync';
  static const String _enableNotesOnlinePrefetch = 'enableNotesOnlinePrefetch';
  static const String _enableTodosOnlinePrefetch = 'enableTodosOnlinePrefetch';

  /// Method to save the JWT token to shared preferences
  static Future<void> saveJwtToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_jwtKey, token);
  }

  /// Method to retrieve the JWT token from shared preferences
  static Future<String?> getJwtToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_jwtKey);
  }

  /// Method to remove the JWT token from shared preferences
  static Future<void> removeJwtToken() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_jwtKey);
  }

  /// Method to set auto-sync
  static Future<void> setAutoSyncStatus(bool value)async{
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enableAutoSync, value);
  }

  /// Method to get if user enabled auto-sync
  static Future<bool?> getAutoSyncStatus()async{
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enableAutoSync);
  }

  /// Method to set [_enableNotesOnlinePrefetch]
  static Future<void> setNotesOnlinePrefetch(bool value)async{
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enableNotesOnlinePrefetch, value);
  }

  /// Method to get [_enableNotesOnlinePrefetch]
  static Future<bool?> getNotesOnlinePrefetchStatus()async{
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enableNotesOnlinePrefetch);
  }

  /// Method to set [_enableTodosOnlinePrefetch]
  static Future<void> setTodosOnlinePrefetch(bool value)async{
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enableTodosOnlinePrefetch, value);
  }

  /// Method to get [_enableTodosOnlinePrefetch]
  static Future<bool?> getTodosOnlinePrefetchStatus()async{
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enableTodosOnlinePrefetch);
  }


}
