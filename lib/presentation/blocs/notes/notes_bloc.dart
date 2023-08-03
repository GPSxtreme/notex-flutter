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
          final updatedNotes =
          await NotesRepository.syncOnlineNotes(onlineFetchedNotes);

          if (updatedNotes.isNotEmpty) {
            emit(NotesFetchedState(updatedNotes));
          } else {
            isFetchedNotesEmpty = true;
          }
        } else {
          isFetchedNotesEmpty = true;
        }
      }

      if (!hasInternet || isFetchedNotesEmpty) {
        final offlineFetchedNotes = await LOCAL_DB.getNotes();

        if (offlineFetchedNotes.isEmpty) {
          emit(NotesEmptyState());
        } else {
          emit(NotesFetchedState(offlineFetchedNotes));
        }
      }
    } catch (error) {
      emit(NotesFetchingFailedState(error.toString()));
    }
  }

}
