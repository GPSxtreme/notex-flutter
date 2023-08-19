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
    on<SettingsUserAccountVerifyEvent>(handleUserVerification);
    on<SettingsUserPasswordResetEvent>(handleUserPasswordReset);
  }

  FutureOr<void> handleFetchSettings(
      SettingsInitialEvent event, Emitter<SettingsState> emit) async {
    try {
      final autoSyncStatus =
          await SharedPreferencesRepository.getAutoSyncStatus();
      emit(SettingsFetchedState(autoSyncStatus ?? false));
    } catch (error) {
      emit(SettingsFetchingFailedState(error.toString()));
    }
  }

  FutureOr<void> handleSetAutoSync(
      SettingsSetAutoSyncEvent event, Emitter<SettingsState> emit) async {
    try {
      await SharedPreferencesRepository.setAutoSyncStatus(event.value);
      emit(SettingsFetchedState(event.value));
    } catch (error) {
      emit(SettingsSnackBarState(error.toString()));
    }
  }

  FutureOr<void> handleUserLogout(
      SettingsUserLogoutEvent event, Emitter<SettingsState> emit) async {
    try {
      final response = await AuthRepository.logoutUser();
      if (response) {
        emit(SettingsUserLogoutState(body: event.body, title: event.title));
      } else {
        emit(SettingsSnackBarState("Failed to logout user"));
      }
    } catch (error) {
      emit(SettingsSnackBarState(error.toString()));
    }
  }

  FutureOr<void> handleUserVerification(
      SettingsUserAccountVerifyEvent event, Emitter<SettingsState> emit) async {
    try {
      await AuthRepository.sendAccountVerificationEmail().then((res) async {
        if (res.success) {
          await AuthRepository.logoutUser();
          emit(SettingsUserLogoutState(
              title: 'Email sent!',
              body: 'You will be logged out to reinitialise login credentials.\n(check spam folder for link if not in inbox)',
              agreeLabel: 'continue',
              isBarrierDismissible: false,
              isSingleButton: true));
        } else {
          emit(SettingsSnackBarState(res.message));
        }
      });
    } catch (error) {
      emit(SettingsSnackBarState(error.toString()));
    }
  }
  FutureOr<void> handleUserPasswordReset (SettingsUserPasswordResetEvent event, Emitter<SettingsState> emit )async{
    try{
      await AuthRepository.sendPasswordResetLink().then((res) async {
        if (res.success) {
          await AuthRepository.logoutUser();
          emit(SettingsUserLogoutState(
              title: 'Email sent!',
              body: 'You will be logged out to reinitialise login credentials.\n(check spam folder for link if not in inbox)',
              agreeLabel: 'continue',
              isBarrierDismissible: false,
              isSingleButton: true));
        } else {
          emit(SettingsSnackBarState(res.message));
        }
      });
    }catch(error){
      emit(SettingsSnackBarState(error.toString()));
    }
  }
}
