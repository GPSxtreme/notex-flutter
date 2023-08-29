
import '../../core/repositories/shared_preferences_repository.dart';

class Settings{
  late bool _isAutoSyncEnabled;
  late bool _isNotesOnlinePrefetchEnabled;
  late bool _isTodosOnlinePrefetchEnabled;
  late bool _isAppLockEnabled;
  late bool _isHiddenNotesLockEnabled;
  late bool _isDeletedNotesLockEnabled;
  late bool _isBiometricOnly;

  bool get isAutoSyncEnabled => _isAutoSyncEnabled;
  bool get isNotesOnlinePrefetchEnabled => _isNotesOnlinePrefetchEnabled;
  bool get isTodosOnlinePrefetchEnabled => _isTodosOnlinePrefetchEnabled;
  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isHiddenNotesLockEnabled => _isHiddenNotesLockEnabled;
  bool get isDeletedNotesLockEnabled => _isDeletedNotesLockEnabled;
  bool get isBiometricOnly => _isBiometricOnly;

  Future<void> setAutoSyncEnabled (bool value) async{
    _isAutoSyncEnabled = value;
    await SharedPreferencesRepository.setAutoSyncStatus(value);
  }
  Future<void> setNotesOnlinePrefetch (bool value) async{
    _isNotesOnlinePrefetchEnabled = value;
    await SharedPreferencesRepository.setNotesOnlinePrefetch(value);
  }
  Future<void> setTodosOnlinePrefetch (bool value) async{
    _isTodosOnlinePrefetchEnabled = value;
    await SharedPreferencesRepository.setTodosOnlinePrefetch(value);
  }
  Future<void> setAppLockEnabled(bool value) async {
    _isAppLockEnabled = value;
    await SharedPreferencesRepository.setAppLockStatus(value);
  }

  Future<void> setHiddenNotesLockEnabled(bool value) async {
    _isHiddenNotesLockEnabled = value;
    await SharedPreferencesRepository.setHiddenNotesLockStatus(value);
  }

  Future<void> setDeletedNotesLockEnabled(bool value) async {
    _isDeletedNotesLockEnabled = value;
    await SharedPreferencesRepository.setDeletedNotesLockStatus(value);
  }

  Future<void> setBiometricOnly(bool value) async {
    _isBiometricOnly = value;
    await SharedPreferencesRepository.setBiometricOnlyStatus(value);
  }

  Future<void> init()async{
    _isAutoSyncEnabled = await SharedPreferencesRepository.getAutoSyncStatus() ?? true;
    _isNotesOnlinePrefetchEnabled = await SharedPreferencesRepository.getNotesOnlinePrefetchStatus() ?? true;
    _isTodosOnlinePrefetchEnabled = await SharedPreferencesRepository.getTodosOnlinePrefetchStatus() ?? true;
    _isAppLockEnabled = await SharedPreferencesRepository.getAppLockStatus() ?? false;
    _isHiddenNotesLockEnabled = await SharedPreferencesRepository.getHiddenNotesLockStatus() ?? true;
    _isDeletedNotesLockEnabled = await SharedPreferencesRepository.getDeletedNotesLockStatus() ?? false;
    _isBiometricOnly = await SharedPreferencesRepository.getBiometricOnlyStatus() ?? false;
  }
}