import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:notex/core/repositories/user_repository.dart';
import '../../../main.dart';
import '../../../data/models/updatable_user_data_model.dart';

part 'create_user_profile_event.dart';

part 'create_user_profile_state.dart';

class CreateUserProfileBloc
    extends Bloc<CreateUserProfileEvent, CreateUserProfileState> {
  CreateUserProfileBloc() : super(CreateUserProfileInitial()) {
    on<CreateUserProfileOpenDatePickerEvent>(
        (event, emit) => emit(CreateUserProfileOpenDatePickerState()));
    on<CreateUserProfileCreateEvent>(handleUserProfileCreate);
  }

  FutureOr<void> handleUserProfileCreate(
      CreateUserProfileCreateEvent event, emit) async {
    // upload profile picture
    try {
      emit(CreateUserProfileLoadingState());
      await UserRepository.updateUserProfilePicture(event.imageFile)
          .then((_) async {
        // update remaining data
        await UserRepository.updateUserData(event.data).then((response) async {
          if (response.success) {
            await USER
                .init()
                .then((_) => emit(CreateUserProfileSuccessState()));
          } else {
            emit(CreateUserProfileFailedState(response.message));
          }
        });
      });
    } catch (e) {
      emit(CreateUserProfileFailedState('Unexpected error occurred : $e'));
    } finally {
      emit(CreateUserProfileLoadedState());
    }
  }
}
