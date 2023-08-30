import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:notex/core/repositories/auth_repository.dart';
import '../../../main.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<SettingsInitialEvent>(handleFetchSettings);
    on<SettingsSetAutoSyncEvent>(handleSetAutoSync);
    on<SettingsUserLogoutEvent>(handleUserLogout);
    on<SettingsUserAccountVerifyEvent>(handleUserVerification);
    on<SettingsUserPasswordResetEvent>(handleUserPasswordReset);
    on<SettingsSetPrefetchCloudNotesEvent>(handleSetOnlineNotesPrefetch);
    on<SettingsSetPrefetchCloudTodosEvent>(handleSetOnlineTodosPrefetch);
    on<SettingsSetAppLockEvent>(handleSetAppLock);
    on<SettingsSetHiddenNotesLockEvent>(handleSetHiddenNotesLock);
    on<SettingsSetDeletedNotesLockEvent>(handleSetDeletedNotesLock);
    on<SettingsSetBiometricOnlyEvent>(handleSetBiometricOnly);
    on<SettingsDeleteAllNotesEvent>((event,emit)async{
      emit(SettingsDeleteAllNotesAction());
    });
    on<SettingsDeleteAllTodosEvent>((event,emit)async{
      emit(SettingsDeleteAllTodosAction());
    });
    on<SettingsRedirectToGithubEvent>((event,emit)async{
      emit(SettingsRedirectToGithubAction());
    });
    on<SettingsRedirectToGithubBugReportEvent>((event,emit)async{
      emit(SettingsRedirectToGithubBugReportAction());
    });
    on<SettingsRedirectToGithubRequestFeatureEvent>((event,emit)async{
      emit(SettingsRedirectToGithubRequestFeatureAction());
    });
    on<SettingsRedirectToDevSiteEvent>((event,emit)async{
      emit(SettingsRedirectToDevSiteAction());
    });
    on<SettingsRedirectToDevMailEvent>((event,emit)async{
      emit(SettingsRedirectToDevMailAction());
    });
    on<SettingsCheckForAppUpdatesEvent>((event,emit)async{
      emit(SettingsCheckForAppUpdateAction());
    });
  }

  SettingsFetchedState settingsFetchedState () => SettingsFetchedState(
      isAutoSyncEnabled: SETTINGS.isAutoSyncEnabled,
      isNotesOnlinePrefetchEnabled: SETTINGS.isNotesOnlinePrefetchEnabled,
      isTodosOnlinePrefetchEnabled: SETTINGS.isTodosOnlinePrefetchEnabled,
      isAppLockEnabled: SETTINGS.isAppLockEnabled,
      isHiddenNotesLockEnabled: SETTINGS.isHiddenNotesLockEnabled,
      isDeletedNotesLockEnabled: SETTINGS.isDeletedNotesLockEnabled,
      isBiometricOnly: SETTINGS.isBiometricOnly);

  FutureOr<void> handleFetchSettings(SettingsInitialEvent event,
      Emitter<SettingsState> emit) async {
    try {
      emit(settingsFetchedState());
    } catch (error) {
      emit(SettingsFetchingFailedState(error.toString()));
    }
  }

  FutureOr<void> handleSetAutoSync(SettingsSetAutoSyncEvent event,
      Emitter<SettingsState> emit) async {
    try {
      await SETTINGS.setAutoSyncEnabled(event.value).then((_)=>emit(settingsFetchedState()));

    } catch (error) {
      emit(SettingsSnackBarAction(error.toString()));
    }
  }

  FutureOr<void> handleSetOnlineNotesPrefetch(
      SettingsSetPrefetchCloudNotesEvent event,
      Emitter<SettingsState> emit) async {
    try {
      await SETTINGS.setNotesOnlinePrefetch(event.value).then((_)=>emit(settingsFetchedState()));
    } catch (error) {
      emit(SettingsSnackBarAction(error.toString()));
    }
  }

  FutureOr<void> handleSetOnlineTodosPrefetch(
      SettingsSetPrefetchCloudTodosEvent event,
      Emitter<SettingsState> emit) async {
    try {
      await SETTINGS.setTodosOnlinePrefetch(event.value).then((_)=>emit(settingsFetchedState()));
    } catch (error) {
      emit(SettingsSnackBarAction(error.toString()));
    }
  }

  FutureOr<void> handleSetAppLock(SettingsSetAppLockEvent event, Emitter<SettingsState> emit) async {
    try {
      await SETTINGS.setAppLockEnabled(event.value).then((_)=>emit(settingsFetchedState()));
    } catch (error) {
      emit(SettingsSnackBarAction(error.toString()));
    }
  }

  FutureOr<void> handleSetHiddenNotesLock(SettingsSetHiddenNotesLockEvent event, Emitter<SettingsState> emit) async {
    try {
      await SETTINGS.setHiddenNotesLockEnabled(event.value).then((_)=>emit(settingsFetchedState()));
    } catch (error) {
      emit(SettingsSnackBarAction(error.toString()));
    }
  }

  FutureOr<void> handleSetDeletedNotesLock(SettingsSetDeletedNotesLockEvent event, Emitter<SettingsState> emit) async {
    try {
      await SETTINGS.setDeletedNotesLockEnabled(event.value).then((_)=>emit(settingsFetchedState()));
    } catch (error) {
      emit(SettingsSnackBarAction(error.toString()));
    }
  }

  FutureOr<void> handleSetBiometricOnly(SettingsSetBiometricOnlyEvent event, Emitter<SettingsState> emit) async {
    try {
      await SETTINGS.setBiometricOnly(event.value).then((_)=>emit(settingsFetchedState()));
    } catch (error) {
      emit(SettingsSnackBarAction(error.toString()));
    }
  }


  FutureOr<void> handleUserLogout(SettingsUserLogoutEvent event,
      Emitter<SettingsState> emit) async {
    try {
      final response = await AuthRepository.logoutUser();
      if (response) {
        emit(SettingsUserLogoutAction(body: event.body, title: event.title));
      } else {
        emit(SettingsSnackBarAction("Failed to logout user"));
      }
    } catch (error) {
      emit(SettingsSnackBarAction(error.toString()));
    }
  }

  FutureOr<void> handleUserVerification(SettingsUserAccountVerifyEvent event,
      Emitter<SettingsState> emit) async {
    try {
      await AuthRepository.sendAccountVerificationEmail().then((res) async {
        if (res.success) {
          await AuthRepository.logoutUser();
          emit(SettingsUserLogoutAction(
              title: 'Email sent!',
              body:
              'You will be logged out to reinitialise login credentials.\n(check spam folder for link if not in inbox)',
              agreeLabel: 'continue',
              isBarrierDismissible: false,
              isSingleButton: true));
        } else {
          emit(SettingsSnackBarAction(res.message));
        }
      });
    } catch (error) {
      emit(SettingsSnackBarAction(error.toString()));
    }
  }

  FutureOr<void> handleUserPasswordReset(SettingsUserPasswordResetEvent event,
      Emitter<SettingsState> emit) async {
    try {
      await AuthRepository.sendPasswordResetLink().then((res) async {
        if (res.success) {
          await AuthRepository.logoutUser();
          emit(SettingsUserLogoutAction(
              title: 'Email sent!',
              body:
              'You will be logged out to reinitialise login credentials.\n(check spam folder for link if not in inbox)',
              agreeLabel: 'continue',
              isBarrierDismissible: false,
              isSingleButton: true));
        } else {
          emit(SettingsSnackBarAction(res.message));
        }
      });
    } catch (error) {
      emit(SettingsSnackBarAction(error.toString()));
    }
  }
}
