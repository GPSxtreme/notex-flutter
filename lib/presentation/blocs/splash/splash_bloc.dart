import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:notex/core/repositories/auth_repository.dart';
import 'package:notex/core/repositories/jwt_decoder_repository.dart';
import 'package:notex/core/repositories/shared_preferences_repository.dart';
import 'package:notex/core/repositories/util_repository.dart';
import 'package:notex/main.dart';
part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitialState()) {
    on<SplashInitialEvent>(splashInitialEvent);
  }

  Future<void> authenticateUser(Emitter emit) async{
    await UtilRepository.checkForUpdate();
    String? userToken = await SharedPreferencesRepository.getJwtToken();
    if (userToken != null) {
      await AuthRepository.init().then(
              (_) async {
            bool isValid = JwtDecoderRepository.verifyJwtToken(userToken);
            if (isValid) {
              try{
                await USER.init();
                emit(SplashUserAuthenticatedState());
              }catch(error){
                emit(SplashRedirectToCreateUserProfilePageAction());
              }
            }
          }
      );
    } else {
      emit(SplashUserNotAuthenticatedState());
    }
  }

  FutureOr<void> splashInitialEvent(
      SplashInitialEvent event, Emitter<SplashState> emit) async {
    emit(SplashLoadingState());
    await Future.delayed(const Duration(seconds: 1));
    //initialize local db
    await LOCAL_DB.init();
    // initialize local settings
    await SETTINGS.init();
    if(SETTINGS.isAppLockEnabled){
      await AuthRepository.authenticateUser(isNotes: false).then(
          (response) async {
            if(response){
              await authenticateUser(emit);
            } else{
              emit(SplashUserLocalAuthenticationFailedState());
            }
          }
      );
    } else{
      await authenticateUser(emit);
    }
  }
}
