part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class SettingsInitialEvent extends SettingsEvent{}

class SettingsOperationFailedEvent extends SettingsEvent{
  final String reason;
  SettingsOperationFailedEvent(this.reason);
}

class SettingsSetAutoSyncEvent extends SettingsEvent{
  final bool value;
  SettingsSetAutoSyncEvent(this.value);
}

class SettingsUserLogoutEvent extends SettingsEvent{}