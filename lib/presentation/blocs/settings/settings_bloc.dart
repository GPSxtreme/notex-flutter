import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:notex/core/repositories/auth_repository.dart';
import 'package:notex/core/repositories/shared_preferences_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<SettingsInitialEvent>(handleFetchSettings);
    on<SettingsSetAutoSyncEvent>(handleSetAutoSync);
    on<SettingsUserLogoutEvent>(handleUserLogout);
  }

  FutureOr<void> handleFetchSettings(SettingsInitialEvent event, Emitter<SettingsState> emit)async{
    try{
      final autoSyncStatus = await SharedPreferencesRepository.getAutoSyncStatus();
      emit(SettingsFetchedState(autoSyncStatus ?? false));
    }catch(error){
      emit(SettingsFetchingFailedState(error.toString()));
    }
  }

  FutureOr<void> handleSetAutoSync(SettingsSetAutoSyncEvent event , Emitter<SettingsState> emit)async{
    try{
      await SharedPreferencesRepository.setAutoSyncStatus(event.value);
      emit(SettingsFetchedState(event.value));
    }catch(error){
      emit(SettingsOperationFailedState(error.toString()));
    }
  }

  FutureOr<void> handleUserLogout(SettingsUserLogoutEvent event , Emitter<SettingsState> emit)async{
    try{
      final response = await AuthRepository.logoutUser();
      if(response){
        emit(SettingsUserLogoutState());
      }else{
        emit(SettingsOperationFailedState("Failed to logout user"));
      }
    } catch(error){
      emit(SettingsOperationFailedState(error.toString()));
    }
  }
}
