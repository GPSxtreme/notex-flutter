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
  List<TodoModel> _temp = [];
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
    emit(TodosEditingState(_doneTodos, _notDoneTodos, areAllSelected: false));
    // Notify the stream listeners about the changes in _selectedTodos
    if (isSelectedTodoStreamClosed) {
      // start stream again
      _selectedTodosController = StreamController<List<TodoModel>>();
    }
    _selectedTodosController.add(_selectedTodos);
  }

  FutureOr<void> handleAreAllTodosSelected(
      TodosAreAllTodosSelectedEvent event, Emitter<TodosState> emit) async {
    if (event.areAllSelected) {
      _temp = [
        ..._doneTodos.where((todo) => !_selectedTodos.contains(todo)).toList(),
        ..._notDoneTodos
            .where((todo) => !_selectedTodos.contains(todo))
            .toList(),
      ];
      _selectedTodos.addAll(_temp); // add items of both done and undone lists.
    } else {
      // similarly remove todos which are added due to event and not added before hand
      if (_temp.length < _selectedTodos.length &&
          _selectedTodos.length == _doneTodos.length + _notDoneTodos.length) {
        _selectedTodos.clear();
        emit(TodosEditingState(_doneTodos, _notDoneTodos,
            selectedTodoIds: null, areAllSelected: false));
      }
      _selectedTodos.removeWhere((todo) => _temp.contains(todo));
    }
    emit(TodosEditingState(_doneTodos, _notDoneTodos,
        selectedTodoIds: [..._selectedTodos.map((e) => e.id).toList()],
        areAllSelected: event.areAllSelected));
  }

  FutureOr<void> handleEditingExit(
      TodosExitedEditingEvent event, Emitter<TodosState> emit) async {
    emit(TodosExitedEditingState());
    emit(TodosFetchedState(_doneTodos, _notDoneTodos));
    // reset _selectedTodos list
    _selectedTodos.clear();
    // reset _temp list
    _temp.clear();
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
      if (_selectedTodos.length == _doneTodos.length + _notDoneTodos.length) {
        emit(TodosSetAllTodosSelectedCheckBoxState(true));
      } else {
        // emit all notes note selected to home page checkbox;
        emit(TodosSetAllTodosSelectedCheckBoxState(false));
      }
      // Notify the stream listeners about the changes in _selectedTodos
      _selectedTodosController.add(_selectedTodos);
      // rebuild to show changes
      emit(TodosEditingState(_doneTodos, _notDoneTodos,
          selectedTodoIds: [..._selectedTodos.map((e) => e.id).toList()]));
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
        // start removing each to-do in selectedTodos list from local database
        for (var todo in _selectedTodos) {
          await TodosRepository.removeTodo(todo.id);
        }
        _temp.clear();
        _selectedTodos.clear();
        if (_doneTodos.isNotEmpty || _notDoneTodos.isNotEmpty) {
          emit(TodosFetchedState(_doneTodos, _notDoneTodos));
        } else {
          emit(TodosEmptyState());
        }
        emit(TodosExitedEditingState());
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
