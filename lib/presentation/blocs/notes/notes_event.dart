part of 'notes_bloc.dart';

@immutable
abstract class NotesEvent {}

class NotesInitialEvent extends NotesEvent {}

class NotesRefetchNotesEvent extends NotesEvent {
  final NoteModel? note;

  NotesRefetchNotesEvent(this.note);
}

class NotesEnteredEditingEvent extends NotesEvent {
}

class NotesAddNoteEvent extends NotesEvent{
  final NoteModel newNote;

  NotesAddNoteEvent(this.newNote);

}

class NotesExitedEditingEvent extends NotesEvent {}

class NotesDeleteSelectedNotesEvent extends NotesEvent {}

class NotesHideSelectedNotesEvent extends NotesEvent{}

class NotesSyncSelectedNotesEvent extends NotesEvent{}

class NotesAreAllNotesSelectedEvent extends NotesEvent {
  final bool areAllSelected;
  NotesAreAllNotesSelectedEvent(this.areAllSelected);
}

class NotesSetAllNotesSelectedCheckBoxEvent extends NotesEvent {
  final bool flag;

  NotesSetAllNotesSelectedCheckBoxEvent(this.flag);
}

class NotesIsNoteSelectedEvent extends NotesEvent{
  final bool isSelected;
  final NoteModel note;

  NotesIsNoteSelectedEvent(this.isSelected, this.note);
}

class NotesSetNoteFavoriteEvent extends NotesEvent{
  final String noteId;
  final bool value;
  NotesSetNoteFavoriteEvent(this.value, this.noteId);
}

class NotesUploadNoteToCloudEvent extends NotesEvent{
  final NoteModel note;
  NotesUploadNoteToCloudEvent(this.note);
}

class NotesSyncAllNotesEvent extends NotesEvent{}