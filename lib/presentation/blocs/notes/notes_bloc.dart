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
  }

  late List<NoteModel> _notes;
  late List<NoteModel> _selectedNotes;

  StreamController<List<NoteModel>> _selectedNotesController =
  StreamController<List<NoteModel>>.broadcast();

  Stream<List<NoteModel>> get selectedTodosStream =>
      _selectedNotesController.stream;

  bool get isSelectedTodoStreamClosed => _selectedNotesController.isClosed;

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
          _notes =
          await NotesRepository.syncOnlineNotes(onlineFetchedNotes);

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

  FutureOr<void> handleRefetchNotes (NotesRefetchNotesEvent event , Emitter<NotesState> emit)async{
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

}
