import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:meta/meta.dart';
import 'package:notex/core/repositories/todos_repository.dart';
import 'package:notex/data/models/todo_model.dart';
import 'package:notex/data/repositories/model_to_entity_repository.dart';
import '../../../main.dart';

part 'todos_event.dart';

part 'todos_state.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  TodosBloc() : super(TodosInitialState()) {
    on<TodosInitialEvent>(handleFetchTodos);
    on<TodosMarkTodoDoneEvent>(handleMarkTodoDone);
    on<TodosMarkTodoNotDoneEvent>(handleMarkTodoNotDone);
  }
  late List<TodoModel> _doneTodos;
  late List<TodoModel> _notDoneTodos;

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
          final updatedTodos =
              await TodosRepository.syncOnlineTodos(onlineFetchedNotes);

          if (updatedTodos.isNotEmpty) {
            _doneTodos = updatedTodos.where((todo) => todo.isCompleted).toList();
            _notDoneTodos = updatedTodos.where((todo) => !todo.isCompleted).toList();
            emit(TodosFetchedState(_doneTodos,_notDoneTodos));
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
          _doneTodos = offlineFetchedNotes.where((todo) => todo.isCompleted).toList();
          _notDoneTodos = offlineFetchedNotes.where((todo) => !todo.isCompleted).toList();
          emit(TodosFetchedState(_doneTodos,_notDoneTodos));
        }
      }
    } catch (error) {
      emit(TodosFetchingFailedState(error.toString()));
    }
  }

  FutureOr<void> handleMarkTodoDone ( TodosMarkTodoDoneEvent event , Emitter<TodosState> emit)async{
    // update local lists in bloc
    _notDoneTodos.removeWhere((todo) => todo.id == event.todo.id);
    _doneTodos.add(event.todo);
    emit(TodosFetchedState(_doneTodos, _notDoneTodos));

    // set to-do as done on local db
    final modifiedTodo = event.todo;
    modifiedTodo.isCompleted = true;
    modifiedTodo.editedTime = DateTime.now();
    await LOCAL_DB.updateTodo(ModelToEntityRepository.mapToTodoEntity(modifiedTodo), false);
    // update task on cloud
  }

  FutureOr<void> handleMarkTodoNotDone(TodosMarkTodoNotDoneEvent event , Emitter<TodosState> emit)async{
    // update local lists in bloc
    _doneTodos.removeWhere((todo) => todo.id == event.todo.id);
    _notDoneTodos.add(event.todo);
    emit(TodosFetchedState(_doneTodos, _notDoneTodos));

    // set to-do as not done on local db
    final modifiedTodo = event.todo;
    modifiedTodo.isCompleted = false;
    modifiedTodo.editedTime = DateTime.now();
    await LOCAL_DB.updateTodo(ModelToEntityRepository.mapToTodoEntity(modifiedTodo), false);

    // update task on cloud
  }

}
