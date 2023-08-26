part of 'notes_bloc.dart';

@immutable
abstract class NotesState {}

abstract class NotesHomeState extends NotesState {}

abstract class NotesActionState extends NotesState {}

abstract class NotesHomeActionState extends NotesActionState {}

class NotesInitialState extends NotesState {}

class NotesFetchingState extends NotesHomeState {}

class NotesFetchedState extends NotesHomeState {
  final List<NoteModel> notes;
  final List<String>? syncingNotes;
  final bool showHiddenNotes;
  NotesFetchedState(
    this.notes, {this.syncingNotes,this.showHiddenNotes = false}
  );
}

class NotesEditingState extends NotesFetchedState {
  NotesEditingState(
      super.notes, { super.syncingNotes ,this.selectedNotesIds, this.areAllSelected = false,super.showHiddenNotes = false});

  final List<String>? selectedNotesIds;
  final bool areAllSelected;
}

class NotesFetchingFailedState extends NotesState {
  final String reason;

  NotesFetchingFailedState(this.reason);
}

class NotesOperationFailedState extends NotesActionState {
  final String reason;

  NotesOperationFailedState(this.reason);
}

class NotesSetAllNotesSelectedCheckBoxState extends NotesHomeActionState {
  final bool flag;

  NotesSetAllNotesSelectedCheckBoxState(this.flag);
}

class NotesLoadingState extends NotesState {}

class NotesLoadedState extends NotesState {}

class NotesEmptyState extends NotesHomeState {
  final bool isInHiddenMode;

  NotesEmptyState({this.isInHiddenMode = false});
}

class NotesEnteredEditingState extends NotesHomeState {
  final bool isInHiddenMode;

  NotesEnteredEditingState({this.isInHiddenMode = false});
}

class NotesExitedEditingState extends NotesHomeState {}
