import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
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
    on<TodosShowAddTodoDialogBoxEvent>(handleAddTodoDialogBox);
    on<TodosAddTodoEvent>(handleAddTodo);
    on<TodosEnteredEditingEvent>(handleEditingEnter);
    on<TodosAreAllTodosSelectedEvent>(handleAreAllTodosSelected);
    on<TodosExitedEditingEvent>(handleEditingExit);
    on<TodosIsTodoSelectedEvent>(handleTodoSelect);
    on<TodosDeleteSelectedTodosEvent>(handleDeleteSelectedTodos);
    on<TodosHideSelectedTodosEvent>(handleHideSelectedTodos);
  }

  late List<TodoModel> _doneTodos;
  late List<TodoModel> _notDoneTodos;
  final List<TodoModel> _selectedTodos = [];

  StreamController<List<TodoModel>> _selectedTodosController =
      StreamController<List<TodoModel>>.broadcast();

  Stream<List<TodoModel>> get selectedTodosStream =>
      _selectedTodosController.stream;

  bool get isSelectedTodoStreamClosed => _selectedTodosController.isClosed;

  @override
  Future<void> close() {
    // close streams
    _selectedTodosController.close();
    return super.close();
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
          final updatedTodos =
              await TodosRepository.syncOnlineTodos(onlineFetchedNotes);

          if (updatedTodos.isNotEmpty) {
            _doneTodos =
                updatedTodos.where((todo) => todo.isCompleted).toList();
            _notDoneTodos =
                updatedTodos.where((todo) => !todo.isCompleted).toList();
            emit(TodosFetchedState(_doneTodos, _notDoneTodos));
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
          _doneTodos =
              offlineFetchedNotes.where((todo) => todo.isCompleted).toList();
          _notDoneTodos =
              offlineFetchedNotes.where((todo) => !todo.isCompleted).toList();
          emit(TodosFetchedState(_doneTodos, _notDoneTodos));
        }
      }
    } catch (error) {
      emit(TodosFetchingFailedState(error.toString()));
    }
  }

  FutureOr<void> handleMarkTodoDone(
      TodosMarkTodoDoneEvent event, Emitter<TodosState> emit) async {
    final modifiedTodo = event.todo;
    modifiedTodo.isCompleted = true;
    modifiedTodo.editedTime = DateTime.now();
    modifiedTodo.isSynced = false;

    // update local lists in bloc
    _notDoneTodos.removeWhere((todo) => todo.id == modifiedTodo.id);
    _doneTodos.insert(0, modifiedTodo);
    emit(TodosFetchedState(_doneTodos, _notDoneTodos));

    // set to-do as done on local db
    await LOCAL_DB.updateTodo(
        ModelToEntityRepository.mapToTodoEntity(model: modifiedTodo));
    // update task on cloud
  }

  FutureOr<void> handleMarkTodoNotDone(
      TodosMarkTodoNotDoneEvent event, Emitter<TodosState> emit) async {
    final modifiedTodo = event.todo;
    modifiedTodo.isCompleted = false;
    modifiedTodo.editedTime = DateTime.now();
    modifiedTodo.isSynced = false;

    // update local lists in bloc
    _doneTodos.removeWhere((todo) => todo.id == modifiedTodo.id);
    _notDoneTodos.insert(0, modifiedTodo);
    emit(TodosFetchedState(_doneTodos, _notDoneTodos));

    // set to-do as not done on local db
    await LOCAL_DB.updateTodo(
        ModelToEntityRepository.mapToTodoEntity(model: modifiedTodo));

    // update task on cloud
  }

  FutureOr<void> handleAddTodoDialogBox(
      TodosShowAddTodoDialogBoxEvent event, Emitter<TodosState> emit) {
    emit(TodosShowAddTodoDialogBoxState());
  }

  FutureOr<void> handleAddTodo(
      TodosAddTodoEvent event, Emitter<TodosState> emit) async {
    try {
      _notDoneTodos.insert(0, event.todo);
      emit(TodosFetchedState(_doneTodos, _notDoneTodos));
      await TodosRepository.addTodo(event.todo).then((_) {
        emit(TodosAddTodoSuccessState());
      });
    } catch (error) {
      emit(TodosAddTodoFailedState('An unexpected error occurred \n $error'));
    }
  }

  FutureOr<void> handleEditingEnter(
      TodosEnteredEditingEvent event, Emitter<TodosState> emit) async {
    emit(TodosEnteredEditingState());
    emit(TodosFetchedState(_doneTodos, _notDoneTodos, isInEditState: true));
    // Notify the stream listeners about the changes in _selectedTodos
    if (isSelectedTodoStreamClosed) {
      // start stream again
      _selectedTodosController = StreamController<List<TodoModel>>();
    }
    _selectedTodosController.add(_selectedTodos);
  }

  FutureOr<void> handleAreAllTodosSelected(
      TodosAreAllTodosSelectedEvent event, Emitter<TodosState> emit) async {
    if (event.areSelected) {
      _selectedTodos.addAll([
        ..._doneTodos,
        ..._notDoneTodos
      ]); // add items of both done and undone lists.
    } else {
      _selectedTodos.clear();
    }
    emit(TodosFetchedState(_doneTodos, _notDoneTodos,
        isInEditState: true, areAllSelected: event.areSelected));
  }

  FutureOr<void> handleEditingExit(
      TodosExitedEditingEvent event, Emitter<TodosState> emit) async {
    emit(TodosExitedEditingState());
    emit(TodosFetchedState(_doneTodos, _notDoneTodos, isInEditState: false));
    // reset _selectedTodos list
    _selectedTodos.clear();
    // Notify the stream listeners about the changes in _selectedTodos
    _selectedTodosController.close();
  }

  FutureOr<void> handleTodoSelect(
      TodosIsTodoSelectedEvent event, Emitter<TodosState> emit) async {
    try {
      if (event.isSelected) {
        // add to _selectedTodos list
        _selectedTodos.add(event.todo);
      } else {
        // remove from _selectedTodos list
        _selectedTodos.remove(event.todo);
      }
      // Notify the stream listeners about the changes in _selectedTodos
      _selectedTodosController.add(_selectedTodos);
    } catch (error) {
      emit(TodosOperationFailedState(error.toString()));
    }
  }

  FutureOr<void> handleDeleteSelectedTodos(
      TodosDeleteSelectedTodosEvent event, Emitter<TodosState> emit) async {
    try {
      // delete all selected todos
      if (_selectedTodos.isEmpty) {
        return;
      } else {
        for (var todo in _selectedTodos) {
          if (_doneTodos.contains(todo)) {
            _doneTodos.remove(todo);
          } else if (_notDoneTodos.contains(todo)) {
            _notDoneTodos.remove(todo);
          }
        }
        if (_doneTodos.isNotEmpty || _notDoneTodos.isNotEmpty) {
          emit(TodosFetchedState(_doneTodos, _notDoneTodos,isInEditState: false));
        } else {
          emit(TodosEmptyState());
        }
        // start removing each to-do in selectedTodos list from local database
        for (var todo in _selectedTodos) {
          await TodosRepository.removeTodo(todo.id);
        }
        emit(TodosExitedEditingState());
        // reset _selectedTodos list
        _selectedTodos.clear();
        // Notify the stream listeners about the changes in _selectedTodos
        _selectedTodosController.close();

      }
    } catch (error) {
      emit(TodosOperationFailedState(error.toString()));
    }
  }

  FutureOr<void> handleHideSelectedTodos(
      TodosHideSelectedTodosEvent event, Emitter<TodosState> emit) async {
    // hide all selected todos
  }
}
