part of 'register_bloc.dart';

@immutable
abstract class RegisterState {}

abstract class RegisterActionState extends RegisterState {}

class RegisterInitialState extends RegisterState {}

class RegisterLoadingState extends RegisterState{}

class RegisterLoadedState extends RegisterState {}

class RegisterEmptyCredentialsState extends RegisterActionState {}

class RegisterPasswordsDoNotMatchState extends RegisterActionState {}

class RegisterFailedState extends RegisterActionState {
  final String reason;
  RegisterFailedState(this.reason);
}

class RegisterSuccessState extends RegisterActionState {}

class RegisterRedirectToLoginState extends RegisterActionState {}