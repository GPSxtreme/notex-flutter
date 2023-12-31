import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:notex/core/repositories/auth_repository.dart';

import '../../../main.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitialState()) {
    on<LoginPageLoginButtonClickedEvent>(processLogin);
    on<LoginPageRegisterButtonClickedEvent>(processRedirectToRegisterPage);
    on<LoginPageForgotPasswordButtonClickedEvent>(processRedirectToPasswordResetPage);
  }

  FutureOr<void> processLogin(
      LoginPageLoginButtonClickedEvent event, Emitter<LoginState> emit) async {
    // login user
    try {
      emit(LoginLoadingSate());
      await AuthRepository.loginUser(
              event.email, event.password, event.rememberDevice)
          .then((response) async {
        if (response.success) {
          await AuthRepository.init().then((_) async {
            try {
              await USER.init();
              emit(LoginSuccessState());
            } catch (error) {
              emit(LoginRedirectToCreateUserProfilePageAction());
            }
          });
        } else {
          emit(LoginFailedState(response.message));
        }
      });
      emit(LoginLoadedState());
    } catch (error) {
      emit(LoginFailedState("An unexpected error occurred"));
    }
  }

  FutureOr<void> processRedirectToRegisterPage(
      LoginPageRegisterButtonClickedEvent event, Emitter<LoginState> emit) {
    emit(LoginNavigateToRegisterPageActionState());
  }
  FutureOr<void> processRedirectToPasswordResetPage(LoginPageForgotPasswordButtonClickedEvent event,Emitter<LoginState> emit){
    emit(LoginRedirectToPasswordResetPageAction());
  }
}
