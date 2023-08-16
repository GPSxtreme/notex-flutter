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

class SettingsOperationFailedState extends SettingsActionState{
  final String reason;
  SettingsOperationFailedState(this.reason);
}

class SettingsUserLogoutState extends SettingsActionState{}