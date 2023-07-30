import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:notex/core/repositories/auth_repository.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitialState()) {
    on<LoginPageLoginButtonClickedEvent>(processLogin);
  }
  FutureOr<void> processLogin(LoginPageLoginButtonClickedEvent event, Emitter<LoginState> emit) async{
    // login user
    try{
      emit(LoginLoadingSate());
      await AuthRepository.loginUser(event.email, event.password, event.rememberDevice).then(
          (response) {
            if(response.success){
              emit(LoginSuccessState());
            } else{
              emit(LoginFailedState(response.message));
            }
          }
      );
      emit(LoginLoadedState());
    } catch(error){
      emit(LoginFailedState("An unexpected error occurred"));
    }
  }
}
