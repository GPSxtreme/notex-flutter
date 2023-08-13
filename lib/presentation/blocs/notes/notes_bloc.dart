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
    on<NotesRefetchNotesEvent>(handleRefetchNotes);
    on<NotesEnteredEditingEvent>(handleEnterEditing);
    on<NotesExitedEditingEvent>(handleExitedEditing);
    on<NotesAreAllNotesSelectedEvent>(handleAreAllNotesSelected);
    on<NotesDeleteSelectedNotesEvent>(handleDeleteNotes);
    on<NotesHideSelectedNotesEvent>(handleHideNotes);
    on<NotesIsNoteSelectedEvent>(handleNoteSelect);
    on<NotesSetAllNotesSelectedCheckBoxEvent>(handleSetAllNotesSelectCheckBox);
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

      if (hasInternet) {
        final fetchResponse = await NotesRepository.fetchNotes();
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

      if (!hasInternet || isFetchedNotesEmpty) {
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

  FutureOr<void> handleRefetchNotes(
      NotesRefetchNotesEvent event, Emitter<NotesState> emit) async {
    if (event.note != null) {
      // Check if the note is new or already existing in _notes list
      final existingIndex = _notes.indexOf(event.note!);

      if (existingIndex != -1) {
        // Replace the existing note with the new note
        _notes.replaceRange(existingIndex, existingIndex + 1, [event.note!]);
        // update note in local db
        await NotesRepository.updateNote(event.note!);
      } else {
        // Push new note at the starting index
        _notes.insert(0, event.note!);
        // add note in local db
        await NotesRepository.addNote(event.note!);
      }
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

  FutureOr<void> handleDeleteNotes(
      NotesDeleteSelectedNotesEvent event, Emitter emit) async {
    try {
      if (_selectedNotes.isEmpty) {
        return;
      } else {
        for (var note in _selectedNotes) {
          _notes.remove(note);
          await NotesRepository.removeNote(note.id);
        }
        _temp.clear();
        _selectedNotes.clear();
        emit(NotesExitedEditingState());
        if (_notes.isNotEmpty) {
          emit(NotesFetchedState(_notes));
        } else {
          emit(NotesEmptyState());
        }
        _selectedNotesController.close();
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
}
