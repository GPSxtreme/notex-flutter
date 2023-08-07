part of 'notes_bloc.dart';

@immutable
abstract class NotesState {}

abstract class NotesActionState extends NotesState {}

class NotesInitialState extends NotesState {}

class NotesFetchingState extends NotesState {}

class NotesFetchedState extends NotesState {
  final List<NoteModel> notes;
  NotesFetchedState(this.notes);
}

class NotesFetchingFailedState extends NotesState {
  final String reason;

  NotesFetchingFailedState(this.reason);
}

class NotesLoadingState extends NotesState{}

class NotesLoadedState extends NotesState{}

class NotesEmptyState extends NotesState {}


class NotesEnteredEditingState extends NotesState {}