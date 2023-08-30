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

class SettingsSetPrefetchCloudNotesEvent extends SettingsEvent{
  final bool value;
  SettingsSetPrefetchCloudNotesEvent(this.value);
}

class SettingsSetPrefetchCloudTodosEvent extends SettingsEvent{
  final bool value;
  SettingsSetPrefetchCloudTodosEvent(this.value);
}

class SettingsSetAppLockEvent extends SettingsEvent {
  final bool value;
  SettingsSetAppLockEvent(this.value);
}

class SettingsSetHiddenNotesLockEvent extends SettingsEvent {
  final bool value;
  SettingsSetHiddenNotesLockEvent(this.value);
}

class SettingsSetDeletedNotesLockEvent extends SettingsEvent {
  final bool value;
  SettingsSetDeletedNotesLockEvent(this.value);
}

class SettingsSetBiometricOnlyEvent extends SettingsEvent {
  final bool value;
  SettingsSetBiometricOnlyEvent(this.value);
}


class SettingsUserLogoutEvent extends SettingsEvent{
  final String? title;
  final String? body;
  SettingsUserLogoutEvent({this.title, this.body});

}

class SettingsUserAccountVerifyEvent extends SettingsEvent{}

class SettingsUserPasswordResetEvent extends SettingsEvent{}

class SettingsDeleteAllNotesEvent extends SettingsEvent{}

class SettingsDeleteAllTodosEvent extends SettingsEvent{}

class SettingsRedirectToGithubEvent extends SettingsEvent{}

class SettingsRedirectToGithubBugReportEvent extends SettingsEvent{}

class SettingsRedirectToGithubRequestFeatureEvent extends SettingsEvent{}

class SettingsRedirectToDevSiteEvent extends SettingsEvent{}

class SettingsRedirectToDevMailEvent extends SettingsEvent{}

class SettingsCheckForAppUpdatesEvent extends SettingsEvent{}
