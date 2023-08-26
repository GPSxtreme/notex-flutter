part of 'notes_bloc.dart';

@immutable
abstract class NotesEvent {
  final bool isInHiddenMode;
  const NotesEvent({this.isInHiddenMode = false});
}

class NotesInitialEvent extends NotesEvent {
  const NotesInitialEvent({super.isInHiddenMode});
}

class NotesRefetchNotesEvent extends NotesEvent {
  final NoteModel? note;

  const NotesRefetchNotesEvent(this.note,{super.isInHiddenMode});
}

class NotesEnteredEditingEvent extends NotesEvent {
  const NotesEnteredEditingEvent({super.isInHiddenMode});
}

class NotesAddNoteEvent extends NotesEvent{
  final NoteModel newNote;

  const NotesAddNoteEvent(this.newNote);
}

class NotesExitedEditingEvent extends NotesEvent {
  const NotesExitedEditingEvent({super.isInHiddenMode});
}

class NotesDeleteSelectedNotesEvent extends NotesEvent {
  const NotesDeleteSelectedNotesEvent({super.isInHiddenMode});
}

class NotesHideSelectedNotesEvent extends NotesEvent{}

class NotesUnHideSelectedNotesEvent extends NotesEvent{
  const NotesUnHideSelectedNotesEvent({super.isInHiddenMode});
}

class NotesSyncSelectedNotesEvent extends NotesEvent{
  const NotesSyncSelectedNotesEvent({super.isInHiddenMode});
}

class NotesAreAllNotesSelectedEvent extends NotesEvent {
  final bool areAllSelected;
  const NotesAreAllNotesSelectedEvent(this.areAllSelected,
      {super.isInHiddenMode});
}

class NotesSetAllNotesSelectedCheckBoxEvent extends NotesEvent {
  final bool flag;
  const NotesSetAllNotesSelectedCheckBoxEvent(this.flag,{super.isInHiddenMode});
}

class NotesIsNoteSelectedEvent extends NotesEvent{
  final bool isSelected;
  final NoteModel note;
  const NotesIsNoteSelectedEvent(this.isSelected, this.note,{super.isInHiddenMode});
}

class NotesSetNoteFavoriteEvent extends NotesEvent{
  final NoteModel note;
  final bool value;
  const NotesSetNoteFavoriteEvent(this.value, this.note);
}

class NotesUploadNoteToCloudEvent extends NotesEvent{
  final NoteModel note;
  const NotesUploadNoteToCloudEvent(this.note);
}

class NotesSyncAllNotesEvent extends NotesEvent{
  const NotesSyncAllNotesEvent({super.isInHiddenMode});
}

class NotesShowHiddenNotesEvent extends NotesEvent {
  final bool value;
  const NotesShowHiddenNotesEvent({this.value = true});

}