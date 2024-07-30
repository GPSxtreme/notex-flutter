import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meta/meta.dart';
import 'package:notex/core/config/api_routes.dart';
import 'package:notex/core/repositories/shared_preferences_repository.dart';
import 'package:notex/core/repositories/user_repository.dart';
import 'package:notex/data/models/updatable_user_data_model.dart';
import 'package:notex/data/models/update_user_data_reponse_model.dart';
import 'package:notex/data/models/user_model.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../main.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<UserInitialEvent>(handleFetchData);
    on<UserUpdateUserDataEvent>(handleUpdateData);
  }

  final CachedNetworkImageProvider img = CachedNetworkImageProvider(
    USER_PROFILE_PICTURE_GET_ROUTE,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': AuthRepository.userToken
    },
    cacheKey: USER.profilePictureCacheKey,
  );

  FutureOr<void> handleFetchData(
      UserInitialEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserFetchingState());

      emit(UserSettingsFetchedState(USER.data!, img));
    } catch (error) {
      emit(UserOperationFailedState(error.toString()));
    }
  }

  FutureOr<void> handleUpdateData(
      UserUpdateUserDataEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserSettingsFetchedState(USER.data!, img, isUpdating: true));
      // update profile picture
      if (event.img != null) {
        bool response =
            await UserRepository.updateUserProfilePicture(event.img!);
        if (!response) {
          emit(UserOperationFailedState("Failed updating profile picture"));
        } else {
          await CachedNetworkImage.evictFromCache(USER.profilePictureCacheKey);
          await SharedPreferencesRepository.generateProfilePictureCacheKey();
        }
      }
      if (event.data != null) {
        if (event.data!.dob.isAfter(DateTime.now())) {
          emit(
              UserOperationFailedState("Date of birth can't be in the future"));
          emit(UserSettingsFetchedState(USER.data!, img));
          return;
        } else if (DateTime.now().difference(event.data!.dob).inDays <
            8 * 365) {
          emit(UserOperationFailedState("Must be at least 8 years old"));
          emit(UserSettingsFetchedState(USER.data!, img));
          return;
        }
        UpdateUserDataResponseModel response =
            await UserRepository.updateUserData(event.data!);
        if (response.success) {
          emit(UserSendScaffoldMessageState(response.message));
          // update login token
          await SharedPreferencesRepository.saveJwtToken(response.token!);
          await AuthRepository.init();
          await USER.init().then((_) {
            emit(UserSettingsFetchedState(USER.data!, img));
          });
        } else {
          emit(UserUpdateUserDataFailedState(response.message));
          emit(UserSettingsFetchedState(USER.data!, img));
        }
      }
    } catch (error) {
      emit(UserOperationFailedState(error.toString()));
    } finally {
      emit(UserResetAfterUpdateState());
    }
  }
}
