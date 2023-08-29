import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SharedPreferencesRepository {
  static const String _jwtKey = 'jwt_token';
  static const String _profilePictureCacheKey = 'profile_picture';
  static const String _enableAutoSync = 'enableAutoSync';
  static const String _enableNotesOnlinePrefetch = 'enableNotesOnlinePrefetch';
  static const String _enableTodosOnlinePrefetch = 'enableTodosOnlinePrefetch';
  static const String _enableAppLock = 'enableAppLock';
  static const String _enableHiddenNotesLock = 'enableHiddenNotesLock';
  static const String _enableDeletedNotesLock = 'enableDeletedNotesLock';
  static const String _enableBiometricOnly = 'enableBiometricOnly';

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

  /// Method to set assign an unique id for [_profilePictureCacheKey]
  static Future<String> generateProfilePictureCacheKey()async{
    final preferences = await SharedPreferences.getInstance();
    var uuid = const Uuid().v4();
    await preferences.setString(uuid, _profilePictureCacheKey);
    return uuid;
  }

  /// Method to get [_profilePictureCacheKey]
  static Future<String?> getProfilePictureCacheKey()async{
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_profilePictureCacheKey);
  }

  /// Method to set app lock status.
  /// [value] is the boolean value to set for app lock.
  static Future<void> setAppLockStatus(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enableAppLock, value);
  }

  /// Method to get if app lock is enabled.
  /// Returns `true` if app lock is enabled, otherwise `false`.
  static Future<bool?> getAppLockStatus() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enableAppLock);
  }

  /// Method to set hidden notes lock status.
  /// [value] is the boolean value to set for hidden notes lock.
  static Future<void> setHiddenNotesLockStatus(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enableHiddenNotesLock, value);
  }

  /// Method to get if hidden notes lock is enabled.
  /// Returns `true` if hidden notes lock is enabled, otherwise `false`.
  static Future<bool?> getHiddenNotesLockStatus() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enableHiddenNotesLock);
  }

  /// Method to set deleted notes lock status.
  /// [value] is the boolean value to set for deleted notes lock.
  static Future<void> setDeletedNotesLockStatus(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enableDeletedNotesLock, value);
  }

  /// Method to get if deleted notes lock is enabled.
  /// Returns `true` if deleted notes lock is enabled, otherwise `false`.
  static Future<bool?> getDeletedNotesLockStatus() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enableDeletedNotesLock);
  }

  /// Method to set biometric only status.
  /// [value] is the boolean value to set for biometric only.
  static Future<void> setBiometricOnlyStatus(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enableBiometricOnly, value);
  }

  /// Method to get if biometric only is enabled.
  /// Returns `true` if biometric only is enabled, otherwise `false`.
  static Future<bool?> getBiometricOnlyStatus() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enableBiometricOnly);
  }
}
