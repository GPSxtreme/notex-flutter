part of 'login_bloc.dart';

@immutable
abstract class LoginState {}
abstract class LoginActionState extends LoginState {}

class LoginInitialState extends LoginState {}

class LoginLoadingSate extends LoginState {}

class LoginLoadedState extends LoginState {}

class LoginFailedState extends LoginActionState {
  final String reason;
  LoginFailedState(this.reason);
}

class LoginSuccessState extends LoginActionState {}

class LoginNavigateToRegisterPageActionState extends LoginActionState {}

class LoginRedirectToCreateUserProfilePageAction extends LoginActionState {}

class LoginRedirectToPasswordResetPageAction extends LoginActionState{}