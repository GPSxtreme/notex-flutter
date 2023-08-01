part of 'create_user_profile_bloc.dart';

@immutable
abstract class CreateUserProfileEvent {}

class CreateUserProfileOpenDatePickerEvent extends CreateUserProfileEvent{}

class CreateUserProfileCreateEvent extends CreateUserProfileEvent {
  final UpdatableUserDataModel data;
  final File imageFile;
  CreateUserProfileCreateEvent(this.data, this.imageFile);
}