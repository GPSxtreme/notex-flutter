part of 'create_user_profile_bloc.dart';

@immutable
abstract class CreateUserProfileState {}

abstract class CreateUserProfileActionState extends CreateUserProfileState{}

class CreateUserProfileInitial extends CreateUserProfileState {}

class CreateUserProfileLoadingState extends CreateUserProfileState {}

class CreateUserProfileLoadedState extends CreateUserProfileState{}

class CreateUserProfileSuccessState extends CreateUserProfileActionState {}

class CreateUserProfileFailedState extends CreateUserProfileActionState {
  final String reason;
  CreateUserProfileFailedState(this.reason);
}

class CreateUserProfileOpenDatePickerState extends CreateUserProfileActionState{}