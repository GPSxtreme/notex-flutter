part of 'notes_bloc.dart';

@immutable
abstract class NotesEvent {}

class NotesInitialEvent extends NotesEvent {}

class NotesRefetchNotesEvent extends NotesEvent {
  final NoteModel? note;

  NotesRefetchNotesEvent(this.note);
}

class NotesEnteredEditingEvent extends NotesEvent {
  final bool isInHiddenMode;

  NotesEnteredEditingEvent({this.isInHiddenMode = false});

}

class NotesAddNoteEvent extends NotesEvent{
  final NoteModel newNote;

  NotesAddNoteEvent(this.newNote);

}

class NotesExitedEditingEvent extends NotesEvent {
  final bool isInHiddenMode;
  NotesExitedEditingEvent({this.isInHiddenMode = false});
}

class NotesDeleteSelectedNotesEvent extends NotesEvent {}

class NotesHideSelectedNotesEvent extends NotesEvent{}

class NotesSyncSelectedNotesEvent extends NotesEvent{}

class NotesAreAllNotesSelectedEvent extends NotesEvent {
  final bool areAllSelected;
  final bool isInHiddenMode;
  NotesAreAllNotesSelectedEvent(this.areAllSelected,{this.isInHiddenMode = false});
}

class NotesSetAllNotesSelectedCheckBoxEvent extends NotesEvent {
  final bool flag;
  final bool isInHiddenMode;
  NotesSetAllNotesSelectedCheckBoxEvent(this.flag,{this.isInHiddenMode = false});
}

class NotesIsNoteSelectedEvent extends NotesEvent{
  final bool isSelected;
  final NoteModel note;
  final bool isInHiddenMode;

  NotesIsNoteSelectedEvent(this.isSelected, this.note,
      {this.isInHiddenMode = false});
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

class NotesShowHiddenNotesEvent extends NotesEvent {
  final bool value;
  NotesShowHiddenNotesEvent({this.value = true});

}