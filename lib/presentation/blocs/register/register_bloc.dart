import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:notex/core/repositories/auth_repository.dart';

import '../../../main.dart';

part 'register_event.dart';

part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitialState()) {
    on<RegisterPageRegisterButtonPressedEvent>(processRegisterUser);
    on<RegisterPageLoginButtonPressedEvent>(processRedirectToLoginPage);
    on<RegisterPageEmptyCredentialsEvent>(processEmptyCredentialsError);
    on<RegisterPagePasswordsDoNotMatchEvent>(processPasswordsDoNotMatchError);
  }

  FutureOr<void> processRegisterUser(
      RegisterPageRegisterButtonPressedEvent event,
      Emitter<RegisterState> emit) async {
    try {
      emit(RegisterLoadingState());
      await AuthRepository.registerUser(
              event.email, event.password, event.rememberDevice)
          .then((response) async {
        if (response.success) {
          await AuthRepository.init().then((_) async {
            await USER.init();
            emit(RegisterSuccessState());
          });
        } else {
          emit(RegisterFailedState(response.message));
        }
      });
      emit(RegisterLoadedState());
    } catch (error) {
      emit(RegisterFailedState("An unexpected error occurred"));
    }
  }

  FutureOr<void> processRedirectToLoginPage(
      RegisterPageLoginButtonPressedEvent event, Emitter<RegisterState> emit) {
    emit(RegisterRedirectToLoginState());
  }

  FutureOr<void> processEmptyCredentialsError(
      RegisterPageEmptyCredentialsEvent event, Emitter<RegisterState> emit) {
    emit(RegisterEmptyCredentialsState());
  }

  FutureOr<void> processPasswordsDoNotMatchError(
      RegisterPagePasswordsDoNotMatchEvent event, Emitter<RegisterState> emit) {
    emit(RegisterPasswordsDoNotMatchState());
  }
}
