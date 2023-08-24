
import '../../core/repositories/shared_preferences_repository.dart';

class Settings{
  late bool _isAutoSyncEnabled;
  late bool _isNotesOnlinePrefetchEnabled;
  late bool _isTodosOnlinePrefetchEnabled;

  bool get isAutoSyncEnabled => _isAutoSyncEnabled;
  bool get isNotesOnlinePrefetchEnabled => _isNotesOnlinePrefetchEnabled;
  bool get isTodosOnlinePrefetchEnabled => _isTodosOnlinePrefetchEnabled;

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

  Future<void> init()async{
    _isAutoSyncEnabled = await SharedPreferencesRepository.getAutoSyncStatus() ?? false;
    _isNotesOnlinePrefetchEnabled = await SharedPreferencesRepository.getNotesOnlinePrefetchStatus() ?? false;
    _isTodosOnlinePrefetchEnabled = await SharedPreferencesRepository.getTodosOnlinePrefetchStatus() ?? false;
  }
}