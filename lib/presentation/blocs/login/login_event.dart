part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}


class LoginPageLoginButtonClickedEvent extends LoginEvent {
  final String email;
  final String password;
  final bool rememberDevice;
  LoginPageLoginButtonClickedEvent(this.email, this.password, this.rememberDevice);
}

class LoginPageRegisterButtonClickedEvent extends LoginEvent {}

class LoginPageForgotPasswordButtonClickedEvent extends LoginEvent{}