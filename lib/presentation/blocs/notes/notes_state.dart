part of 'notes_bloc.dart';

@immutable
abstract class NotesState {
  final bool isInHiddenMode;
  final bool isInDeletedMode;
  const NotesState({this.isInHiddenMode = false,this.isInDeletedMode = false});
}

abstract class NotesHomeState extends NotesState {
  const NotesHomeState({super.isInHiddenMode,super.isInDeletedMode});
}

abstract class NotesActionState extends NotesState {}

abstract class NotesHomeActionState extends NotesActionState {}

class NotesInitialState extends NotesState {}

class NotesFetchingState extends NotesHomeState {}

class NotesFetchedState extends NotesHomeState {
  final List<NoteModel> notes;
  final List<String>? syncingNotes;
  const NotesFetchedState(
    this.notes, {this.syncingNotes,super.isInHiddenMode,super.isInDeletedMode}
  );
}

class NotesEditingState extends NotesFetchedState {
  const NotesEditingState(
      super.notes, { super.syncingNotes ,this.selectedNotesIds, this.areAllSelected = false,super.isInHiddenMode,super.isInDeletedMode});

  final List<String>? selectedNotesIds;
  final bool areAllSelected;
}

class NotesFetchingFailedState extends NotesState {
  final String reason;
  const NotesFetchingFailedState(this.reason,{super.isInHiddenMode,super.isInDeletedMode});
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
  const NotesEmptyState({super.isInHiddenMode,super.isInDeletedMode});
}

class NotesEnteredEditingState extends NotesHomeState {
  const NotesEnteredEditingState({super.isInHiddenMode,super.isInDeletedMode});
}

class NotesExitedEditingState extends NotesHomeState {
  const NotesExitedEditingState({super.isInHiddenMode,super.isInDeletedMode});
}
