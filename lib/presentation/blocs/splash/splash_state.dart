part of 'splash_bloc.dart';

@immutable
abstract class SplashState {}

abstract class SplashActionState extends SplashState {}

class SplashInitialState extends SplashState {}

class SplashLoadingState extends SplashState {}

class SplashUserNotAuthenticatedState extends SplashState {}

class SplashUserAuthenticatedState extends SplashState{}