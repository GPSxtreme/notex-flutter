part of 'settings_bloc.dart';

@immutable
abstract class SettingsState {}

abstract class SettingsActionState extends SettingsState{}

class SettingsInitial extends SettingsState {}

class SettingsFetchingState extends SettingsState{}

class SettingsFetchingFailedState extends SettingsState{
  final String reason;
  SettingsFetchingFailedState(this.reason);
}

class SettingsFetchedState extends SettingsState{
  final bool isAutoSyncEnabled;

  SettingsFetchedState(this.isAutoSyncEnabled);
}

class SettingsSnackBarState extends SettingsActionState{
  final String reason;
  SettingsSnackBarState(this.reason);
}

class SettingsUserLogoutState extends SettingsActionState{
  final String? title;
  final String? body;
  final String? agreeLabel;
  final String? disagreeLabel;
  final bool isSingleButton;
  final bool isBarrierDismissible;
  SettingsUserLogoutState({this.title, this.body,this.agreeLabel, this.disagreeLabel, this.isSingleButton = false,this.isBarrierDismissible = true});
}
