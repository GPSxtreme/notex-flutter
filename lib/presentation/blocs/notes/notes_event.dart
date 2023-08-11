part of 'notes_bloc.dart';

@immutable
abstract class NotesEvent {}

class NotesInitialEvent extends NotesEvent {}

class NotesRefetchNotesEvent extends NotesEvent {
  final NoteModel? note;

  NotesRefetchNotesEvent(this.note);
}