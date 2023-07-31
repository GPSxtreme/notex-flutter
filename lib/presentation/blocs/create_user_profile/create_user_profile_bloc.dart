import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'create_user_profile_event.dart';
part 'create_user_profile_state.dart';

class CreateUserProfileBloc extends Bloc<CreateUserProfileEvent, CreateUserProfileState> {
  CreateUserProfileBloc() : super(CreateUserProfileInitial()) {
    on<CreateUserProfileEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
