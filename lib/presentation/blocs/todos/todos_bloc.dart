import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:meta/meta.dart';
import 'package:notex/core/repositories/todos_repository.dart';
import 'package:notex/data/models/todo_model.dart';
import '../../../main.dart';

part 'todos_event.dart';

part 'todos_state.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  TodosBloc() : super(TodosInitialState()) {
    on<TodosInitialEvent>(handleFetchTodos);
  }

  Future<void> handleFetchTodos(
      TodosInitialEvent event, Emitter<TodosState> emit) async {
    try {
      emit(TodosFetchingState());

      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi);

      bool isFetchedNotesEmpty = false;

      if (hasInternet) {
        final fetchResponse = await TodosRepository.fetchTodos();
        if (fetchResponse.success && fetchResponse.todos!.isNotEmpty) {
          final onlineFetchedNotes = fetchResponse.todos!;
          final updatedNotes =
              await TodosRepository.syncOnlineTodos(onlineFetchedNotes);

          if (updatedNotes.isNotEmpty) {
            emit(TodosFetchedState(updatedNotes));
          } else {
            isFetchedNotesEmpty = true;
          }
        } else {
          isFetchedNotesEmpty = true;
        }
      }

      if (!hasInternet || isFetchedNotesEmpty) {
        final offlineFetchedNotes = await LOCAL_DB.getTodos();

        if (offlineFetchedNotes.isEmpty) {
          emit(TodosEmptyState());
        } else {
          emit(TodosFetchedState(offlineFetchedNotes));
        }
      }
    } catch (error) {
      emit(TodosFetchingFailedState(error.toString()));
    }
  }
}
