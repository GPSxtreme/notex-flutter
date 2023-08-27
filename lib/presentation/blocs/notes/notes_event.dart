part of 'notes_bloc.dart';

@immutable
abstract class NotesEvent {
  final bool isInHiddenMode;
  final bool isInDeletedMode;
  const NotesEvent({this.isInHiddenMode = false,this.isInDeletedMode = false});
}

class NotesInitialEvent extends NotesEvent {
  const NotesInitialEvent({super.isInHiddenMode,super.isInDeletedMode});
}

class NotesRefetchNotesEvent extends NotesEvent {
  final NoteModel? note;

  const NotesRefetchNotesEvent(this.note,{super.isInHiddenMode,super.isInDeletedMode});
}

class NotesEnteredEditingEvent extends NotesEvent {
  const NotesEnteredEditingEvent({super.isInHiddenMode,super.isInDeletedMode});
}

class NotesAddNoteEvent extends NotesEvent{
  final NoteModel newNote;

  const NotesAddNoteEvent(this.newNote);
}

class NotesExitedEditingEvent extends NotesEvent {
  const NotesExitedEditingEvent({super.isInHiddenMode,super.isInDeletedMode});
}

class NotesDeleteSelectedNotesEvent extends NotesEvent {
  const NotesDeleteSelectedNotesEvent({super.isInHiddenMode,super.isInDeletedMode});
}

class NotesHideSelectedNotesEvent extends NotesEvent{}

class NotesUnHideSelectedNotesEvent extends NotesEvent{
  const NotesUnHideSelectedNotesEvent({super.isInHiddenMode,super.isInDeletedMode});
}

class NotesSyncSelectedNotesEvent extends NotesEvent{
  const NotesSyncSelectedNotesEvent({super.isInHiddenMode,super.isInDeletedMode});
}

class NotesAreAllNotesSelectedEvent extends NotesEvent {
  final bool areAllSelected;
  const NotesAreAllNotesSelectedEvent(this.areAllSelected,
      {super.isInHiddenMode,super.isInDeletedMode});
}

class NotesSetAllNotesSelectedCheckBoxEvent extends NotesEvent {
  final bool flag;
  const NotesSetAllNotesSelectedCheckBoxEvent(this.flag,{super.isInHiddenMode,super.isInDeletedMode});
}

class NotesIsNoteSelectedEvent extends NotesEvent{
  final bool isSelected;
  final NoteModel note;
  const NotesIsNoteSelectedEvent(this.isSelected, this.note,{super.isInHiddenMode,super.isInDeletedMode});
}

class NotesSetNoteFavoriteEvent extends NotesEvent{
  final NoteModel note;
  final bool value;
  const NotesSetNoteFavoriteEvent(this.value, this.note,{super.isInHiddenMode});
}

class NotesUploadNoteToCloudEvent extends NotesEvent{
  final NoteModel note;
  const NotesUploadNoteToCloudEvent(this.note);
}

class NotesSyncAllNotesEvent extends NotesEvent{
  const NotesSyncAllNotesEvent({super.isInHiddenMode,super.isInDeletedMode});
}

class NotesShowHiddenNotesEvent extends NotesEvent {
  final bool value;
  const NotesShowHiddenNotesEvent({this.value = true});
}

class NotesShowDeletedNotesEvent extends NotesEvent {
  final bool value;
  const NotesShowDeletedNotesEvent({this.value = true});
}

class NotesRestoreDeletedNoteEvent extends NotesEvent {
  final NoteModel note;
  const NotesRestoreDeletedNoteEvent(this.note);
}