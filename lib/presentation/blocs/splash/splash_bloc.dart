import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:notex/core/repositories/jwt_decoder_repository.dart';
import 'package:notex/core/repositories/shared_preferences_repository.dart';
part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitialState()) {
    on<SplashInitialEvent>(splashInitialEvent);
  }

  FutureOr<void> splashInitialEvent(
      SplashInitialEvent event, Emitter<SplashState> emit) async {
    emit(SplashLoadingState());
    await Future.delayed(const Duration(seconds: 3));
    String? userToken = await SharedPreferencesRepository.getJwtToken();
    if(userToken != null){
      bool isValid =  JwtDecoderRepository.verifyJwtToken(userToken);
      final tokenData = JwtDecoderRepository.decodeJwtToken(userToken);
      if (kDebugMode) {
        // TODO: remove debug print statements
        print(tokenData);
      }
      if(isValid){
        emit(SplashUserAuthenticatedState());
      }
    } else {
      emit(SplashUserNotAuthenticatedState());
    }
  }
}
