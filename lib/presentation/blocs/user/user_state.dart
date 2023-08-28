part of 'user_bloc.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

abstract class UserActionState extends UserState{}

class UserFetchingState extends UserState{}

class UserSettingsFetchedState extends UserState{
  final UserDataModel user;
  final CachedNetworkImageProvider profilePicture;
  final bool isUpdating;
  UserSettingsFetchedState(this.user, this.profilePicture, {this.isUpdating = false});
}

class UserOperationFailedState extends UserActionState{
  final String reason;
  UserOperationFailedState(this.reason);
}

class UserSendScaffoldMessageState extends UserActionState{
  final String message;
  UserSendScaffoldMessageState(this.message);
}

class UserUpdateUserDataFailedState extends UserActionState{
  final String reason;
  UserUpdateUserDataFailedState(this.reason);
}

class UserResetAfterUpdateState extends UserActionState{}