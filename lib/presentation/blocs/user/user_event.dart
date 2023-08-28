part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class UserInitialEvent extends UserEvent{}

class UserUpdateUserDataEvent extends UserEvent{
  final File? img;
  final UpdatableUserDataModel? data;
  UserUpdateUserDataEvent({this.img, this.data});
}