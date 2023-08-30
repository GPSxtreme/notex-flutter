part of 'settings_bloc.dart';

@immutable
abstract class SettingsState {}

abstract class SettingsActionState extends SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsFetchingState extends SettingsState {}

class SettingsFetchingFailedState extends SettingsState {
  final String reason;

  SettingsFetchingFailedState(this.reason);
}

class SettingsFetchedState extends SettingsState {
  final bool isAutoSyncEnabled;
  final bool isNotesOnlinePrefetchEnabled;
  final bool isTodosOnlinePrefetchEnabled;
  final bool isAppLockEnabled;
  final bool isHiddenNotesLockEnabled;
  final bool isDeletedNotesLockEnabled;
  final bool isBiometricOnly;

  SettingsFetchedState(
      {required this.isAutoSyncEnabled,
      required this.isNotesOnlinePrefetchEnabled,
      required this.isTodosOnlinePrefetchEnabled,
      required this.isAppLockEnabled,
      required this.isHiddenNotesLockEnabled,
      required this.isDeletedNotesLockEnabled,
      required this.isBiometricOnly});
}

class SettingsSnackBarAction extends SettingsActionState {
  final String reason;

  SettingsSnackBarAction(this.reason);
}

class SettingsUserLogoutAction extends SettingsActionState {
  final String? title;
  final String? body;
  final String? agreeLabel;
  final String? disagreeLabel;
  final bool isSingleButton;
  final bool isBarrierDismissible;

  SettingsUserLogoutAction(
      {this.title,
      this.body,
      this.agreeLabel,
      this.disagreeLabel,
      this.isSingleButton = false,
      this.isBarrierDismissible = true});
}

class SettingsDeleteAllNotesAction extends SettingsActionState{}

class SettingsDeleteAllTodosAction extends SettingsActionState{}

class SettingsRedirectToGithubAction extends SettingsActionState{}

class SettingsRedirectToGithubBugReportAction extends SettingsActionState{}

class SettingsRedirectToGithubRequestFeatureAction extends SettingsActionState{}

class SettingsRedirectToDevSiteAction extends SettingsActionState{}

class SettingsRedirectToDevMailAction extends SettingsActionState{}

class SettingsCheckForAppUpdateAction extends SettingsActionState{}
