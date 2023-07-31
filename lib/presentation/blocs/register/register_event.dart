part of 'register_bloc.dart';

@immutable
abstract class RegisterEvent {}

class RegisterPageEmptyCredentialsEvent extends RegisterEvent {}

class RegisterPagePasswordsDoNotMatchEvent extends RegisterEvent {}

class RegisterPageRegisterButtonPressedEvent extends RegisterEvent {
  final String email;
  final String password;
  final bool rememberDevice;
  RegisterPageRegisterButtonPressedEvent(this.email, this.password, this.rememberDevice);
}

class RegisterPageLoginButtonPressedEvent extends RegisterEvent {}