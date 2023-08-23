import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:meta/meta.dart';
import 'package:notex/core/repositories/notes_repository.dart';
import 'package:notex/main.dart';
import '../../../data/models/note_model.dart';

part 'notes_event.dart';

part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc() : super(NotesInitialState()) {
    on<NotesInitialEvent>(handleFetchNotes);
    on<NotesAddNoteEvent>(handleAddNote);
    on<NotesRefetchNotesEvent>(handleRefetchNotes);
    on<NotesEnteredEditingEvent>(handleEnterEditing);
    on<NotesExitedEditingEvent>(handleExitedEditing);
    on<NotesAreAllNotesSelectedEvent>(handleAreAllNotesSelected);
    on<NotesDeleteSelectedNotesEvent>(handleDeleteNotes);
    on<NotesHideSelectedNotesEvent>(handleHideNotes);
    on<NotesIsNoteSelectedEvent>(handleNoteSelect);
    on<NotesSetAllNotesSelectedCheckBoxEvent>(handleSetAllNotesSelectCheckBox);
    on<NotesSetNoteFavoriteEvent>(handleSetNoteFavorite);
    on<NotesUploadNoteToCloudEvent>(handleUploadNoteToCloud);
    on<NotesSyncSelectedNotesEvent>(handleSyncSelectedNotes);
  }

  late List<NoteModel> _notes;
  final List<NoteModel> _selectedNotes = [];
  List<NoteModel> _temp = [];

  StreamController<List<NoteModel>> _selectedNotesController =
      StreamController<List<NoteModel>>.broadcast();

  Stream<List<NoteModel>> get selectedNotesStream =>
      _selectedNotesController.stream;

  bool get isSelectedNotesStreamClosed => _selectedNotesController.isClosed;

  @override
  Future<void> close() {
    // close streams
    _selectedNotesController.close();
    return super.close();
  }

  Future<void> handleFetchNotes(
      NotesInitialEvent event, Emitter<NotesState> emit) async {
    try {
      emit(NotesFetchingState());

      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi);

      bool isFetchedNotesEmpty = false;

      if (hasInternet && SETTINGS.isNotesOnlinePrefetchEnabled) {
        final fetchResponse = await NotesRepository.fetchNotesFromOnline();
        if (fetchResponse.success && fetchResponse.notes!.isNotEmpty) {
          final onlineFetchedNotes = fetchResponse.notes!;
          _notes = await NotesRepository.syncOnlineNotes(onlineFetchedNotes);

          if (_notes.isNotEmpty) {
            emit(NotesFetchedState(_notes));
          } else {
            isFetchedNotesEmpty = true;
          }
        } else {
          isFetchedNotesEmpty = true;
        }
      }

      if (!hasInternet || isFetchedNotesEmpty || !SETTINGS.isNotesOnlinePrefetchEnabled) {
        _notes = await LOCAL_DB.getNotes();

        if (_notes.isEmpty) {
          emit(NotesEmptyState());
        } else {
          emit(NotesFetchedState(_notes));
        }
      }
    } catch (error) {
      emit(NotesFetchingFailedState(error.toString()));
    }
  }

  FutureOr<void> handleAddNote(
      NotesAddNoteEvent event, Emitter<NotesState> emit) async {
    try {
      _notes.insert(0, event.newNote);
      emit(NotesFetchedState(_notes, syncingNotes: [event.newNote.id]));
      // insert new note.
      final response = await NotesRepository.addNote(event.newNote);
      if (response["success"] == true) {
        _notes.first.updateId(response["id"]);
        _notes.first.updateIsSynced(true);
        _notes.first.setIsUploaded(true);
      } else if (SETTINGS.isAutoSyncEnabled) {
        emit(NotesOperationFailedState('Failed syncing note'));
      }
      emit(NotesFetchedState(_notes, syncingNotes: null));
    } catch (error) {
      emit(NotesOperationFailedState(error.toString()));
    }
  }
  FutureOr<void> handleUploadNoteToCloud(
      NotesUploadNoteToCloudEvent event, Emitter<NotesState> emit) async {
    try {
      int noteIndex = _notes.indexWhere((n) => n.id == event.note.id);
      emit(NotesFetchedState(_notes, syncingNotes: [event.note.id]));
      // insert new note.
      final response = await NotesRepository.addNoteToCloud(event.note,manualUpload: true);
      if (response["success"] == true) {
        _notes[noteIndex].updateId(response["id"]);
        _notes[noteIndex].updateIsSynced(true);
        _notes[noteIndex].setIsUploaded(true);
      } else if (SETTINGS.isAutoSyncEnabled) {
        emit(NotesOperationFailedState('Failed syncing note'));
      }
      emit(NotesFetchedState(_notes, syncingNotes: null));
    } catch (error) {
      emit(NotesOperationFailedState(error.toString()));
    }
  }

  FutureOr<void> handleSyncSelectedNotes(NotesSyncSelectedNotesEvent event , Emitter<NotesState> emit)async{
    try{
      if (_selectedNotes.isEmpty) {
        return;
      } else {
        _selectedNotesController.close();
        emit(NotesExitedEditingState());
        List<NoteModel> selectedNotesCopy = List.from(_selectedNotes.where((n) => !n.isSynced).toList());
        if(selectedNotesCopy.isEmpty){
          emit(NotesOperationFailedState('All notes are synced 🚀'));
          emit(NotesFetchedState(_notes));
          return;
        }
        emit(NotesFetchedState(_notes, syncingNotes: [
          ...selectedNotesCopy.map((e) => e.id).toList()
        ])); // emit that notes are being synced/being deleted
        await Future.forEach(selectedNotesCopy, (note) async {
          await NotesRepository.updateNoteInCloud(note,manualUpload: true).then(
              (response){
                if(response.success) {
                  _notes[_notes.indexWhere((n) => n.id == note.id)].updateIsSynced(true);
                }
              }
          );
        }).then((_) {
          // after all the iterations of the for loop the remaining code should execute
          _selectedNotes.clear();
          _temp.clear();
          if (_notes.isNotEmpty) {
            emit(NotesFetchedState(_notes, syncingNotes: null));
          } else {
            emit(NotesEmptyState());
          }
        });
      }
    }catch(error){
      emit(NotesOperationFailedState(error.toString()));
    }
  }

  FutureOr<void> handleRefetchNotes(
      NotesRefetchNotesEvent event, Emitter<NotesState> emit) async {
    final note = event.note;
    if (note != null) {
      // Check if the note is new or already existing in _notes list
      int existingIndex = _notes.indexWhere((element) => element.id == note.id);

      if (existingIndex != -1) {
        // Remove the existing note
        _notes.removeAt(existingIndex);
        // update note in local db
        await NotesRepository.updateNote(note);
      } else {
        // add note in local db
        await NotesRepository.addNote(note);
      }
      // Push new note at the starting index
      _notes.insert(0, note);
    }
    emit(NotesFetchedState(_notes));
  }

  FutureOr<void> handleEnterEditing(
      NotesEnteredEditingEvent event, Emitter emit) async {
    emit(NotesEnteredEditingState());
    emit(NotesEditingState(_notes, areAllSelected: false));
    // Notify the stream listeners about the changes in _selectedTodos
    if (isSelectedNotesStreamClosed) {
      // start stream again
      _selectedNotesController = StreamController<List<NoteModel>>();
    }
    _selectedNotesController.add(_selectedNotes);
  }

  FutureOr<void> handleExitedEditing(
      NotesExitedEditingEvent event, Emitter emit) async {
    emit(NotesExitedEditingState());
    emit(NotesFetchedState(_notes));
    // reset _selectedTodos list
    _selectedNotes.clear();
    // reset _temp list
    _temp.clear();
    // Notify the stream listeners about the changes in _selectedTodos
    _selectedNotesController.close();
  }

  FutureOr<void> handleAreAllNotesSelected(
      NotesAreAllNotesSelectedEvent event, Emitter<NotesState> emit) async {
    if (event.areAllSelected) {
      // add notes which are not included in _selected notes before hand
      _temp = _notes.where((note) => !_selectedNotes.contains(note)).toList();
      _selectedNotes.addAll(_temp);
    } else {
      // similarly remove notes which are added due to event and not added before hand
      if (_temp.length < _selectedNotes.length &&
          _selectedNotes.length == _notes.length) {
        _selectedNotes.clear();
        emit(NotesEditingState(_notes,
            selectedNotesIds: null, areAllSelected: false));
      }
      _selectedNotes.removeWhere((note) => _temp.contains(note));
    }
    emit(NotesEditingState(_notes,
        selectedNotesIds: [..._selectedNotes.map((note) => note.id).toList()],
        areAllSelected: event.areAllSelected));
  }

  Future<void> handleDeleteNotes(
      NotesDeleteSelectedNotesEvent event, Emitter emit) async {
    try {
      if (_selectedNotes.isEmpty) {
        return;
      } else {
        _selectedNotesController.close();
        emit(NotesExitedEditingState());
        var selectedNotesCopy = List.from(_selectedNotes);
        emit(NotesFetchedState(_notes, syncingNotes: [
          ..._selectedNotes.map((e) => e.id).toList()
        ])); // emit that notes are being synced/being deleted
        await Future.forEach(selectedNotesCopy, (note) async {
          _selectedNotes.remove(note);
          _notes.remove(note);
          await NotesRepository.removeNote(note
              .id); // should go to next iteration until this operation is completed
        }).then((_) {
          // after all the iterations of the for loop the remaining code should execute
          _selectedNotes.clear();
          _temp.clear();
          if (_notes.isNotEmpty) {
            emit(NotesFetchedState(_notes, syncingNotes: null));
          } else {
            emit(NotesEmptyState());
          }
        });
      }
    } catch (error) {
      emit(NotesOperationFailedState(error.toString()));
    }
  }

  FutureOr<void> handleHideNotes(
      NotesHideSelectedNotesEvent event, Emitter<NotesState> emit) async {}

  FutureOr<void> handleNoteSelect(
      NotesIsNoteSelectedEvent event, Emitter<NotesState> emit) async {
    try {
      if (event.isSelected) {
        // add to _selectedNotes list
        _selectedNotes.add(event.note);
      } else {
        // remove from _selectedNotes list
        _selectedNotes.remove(event.note);
      }
      if (_selectedNotes.length == _notes.length) {
        // emit all notes selected to home page checkbox;
        emit(NotesSetAllNotesSelectedCheckBoxState(true));
      } else {
        // emit all notes note selected to home page checkbox;
        emit(NotesSetAllNotesSelectedCheckBoxState(false));
      }
      // Notify the stream listeners about the changes in _selectedNotes
      _selectedNotesController.add(_selectedNotes);
      // rebuild to show changes
      emit(NotesEditingState(_notes,
          selectedNotesIds: [..._selectedNotes.map((e) => e.id).toList()]));
    } catch (error) {
      emit(NotesOperationFailedState(error.toString()));
    }
  }

  FutureOr<void> handleSetAllNotesSelectCheckBox(
      NotesSetAllNotesSelectedCheckBoxEvent event, Emitter emit) {
    emit(NotesSetAllNotesSelectedCheckBoxState(event.flag));
    emit(NotesEditingState(_notes,
        areAllSelected: false,
        selectedNotesIds: [..._selectedNotes.map((e) => e.id).toList()]));
  }

  FutureOr<void> handleSetNoteFavorite(
      NotesSetNoteFavoriteEvent event, Emitter<NotesState> emit) async {
    try {
      await NotesRepository.setNoteFavorite(event.noteId, event.value);
      _notes[_notes.indexWhere((n) => n.id == event.noteId)]
          .setIsFavorite(event.value);
      _notes[_notes.indexWhere((n) => n.id == event.noteId)]
          .updateIsSynced(false);
      emit(NotesFetchedState(_notes));
    } catch (error) {
      emit(NotesOperationFailedState(error.toString()));
    }
  }
}
