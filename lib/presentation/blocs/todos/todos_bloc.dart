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
    on<TodosUploadTodosToCloudEvent>(handleUploadTodosToCloud);
    on<TodosSyncSelectedTodosEvent>(handleSyncSelectedTodos);
    on<TodosSyncAllTodosEvent>(handleSyncAllTodos);
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

      if (hasInternet && SETTINGS.isTodosOnlinePrefetchEnabled) {
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

      if (!hasInternet ||
          isFetchedNotesEmpty ||
          !SETTINGS.isTodosOnlinePrefetchEnabled) {
        final offlineFetchedNotes = await LOCAL_DB.getTodos();

        if (offlineFetchedNotes.isEmpty) {
          _notDoneTodos = [];
          _doneTodos = [];
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
    event.todo.setEditedTime(DateTime.now());
    event.todo.setIsSynced(false);
    event.todo.setIsCompleted(true);

    // update local lists in bloc
    _notDoneTodos.removeWhere((todo) => todo.id == event.todo.id);
    _doneTodos.insert(0, event.todo);
    emit(TodosFetchedState(_doneTodos, _notDoneTodos));
    // set to-do as not done on local db
    await LOCAL_DB
        .updateTodo(ModelToEntityRepository.mapToTodoEntity(model: event.todo));
  }

  FutureOr<void> handleMarkTodoNotDone(
      TodosMarkTodoNotDoneEvent event, Emitter<TodosState> emit) async {
    event.todo.setEditedTime(DateTime.now());
    event.todo.setIsSynced(false);
    event.todo.setIsCompleted(false);

    // update local lists in bloc
    _doneTodos.removeWhere((todo) => todo.id == event.todo.id);
    _notDoneTodos.insert(0, event.todo);
    emit(TodosFetchedState(_doneTodos, _notDoneTodos));
    // set to-do as not done on local db
    await LOCAL_DB
        .updateTodo(ModelToEntityRepository.mapToTodoEntity(model: event.todo));
  }

  FutureOr<void> handleAddTodoDialogBox(
      TodosShowAddTodoDialogBoxEvent event, Emitter<TodosState> emit) {
    emit(TodosShowAddTodoDialogBoxState());
  }

  FutureOr<void> handleAddTodo(
      TodosAddTodoEvent event, Emitter<TodosState> emit) async {
    try {
      _notDoneTodos.insert(0, event.todo);
      emit(TodosFetchedState(_doneTodos, _notDoneTodos,
          syncingTodos: [event.todo.id]));
      //insert new to-do
      final response = await TodosRepository.addTodo(event.todo);
      if (response['success'] == true) {
        _notDoneTodos.first.updateId(response['id']);
        _notDoneTodos.first.setIsSynced(true);
        _notDoneTodos.first.setIsUploaded(true);
      } else if (SETTINGS.isAutoSyncEnabled) {
        emit(TodosOperationFailedState('Failed syncing todo'));
      }
      emit(TodosFetchedState(_doneTodos, _notDoneTodos, syncingTodos: null));
    } catch (error) {
      emit(TodosAddTodoFailedState('An unexpected error occurred \n $error'));
    }
  }

  FutureOr<void> handleUploadTodosToCloud(
      TodosUploadTodosToCloudEvent event, Emitter<TodosState> emit) async {
    try {
      emit(TodosFetchedState(_doneTodos, _notDoneTodos,
          syncingTodos: event.todos.map((t) => t.id).toList()));
      await Future.forEach(event.todos, (todo) async {
        final refTodoList = _notDoneTodos.any((t) => t.id == todo.id)
            ? _notDoneTodos
            : _doneTodos;
        final todoIndex = refTodoList.indexWhere((t) => t.id == todo.id);
        // insert new note.
        final response =
            await TodosRepository.addTodoToCloud(todo, manualUpload: true);
        if (response["success"] == true) {
          refTodoList[todoIndex].updateId(response["id"]);
          refTodoList[todoIndex].setIsSynced(true);
          refTodoList[todoIndex].setIsUploaded(true);
        } else if (SETTINGS.isAutoSyncEnabled) {
          emit(TodosOperationFailedState('Failed syncing todo'));
        }
      }).then((_) => emit(TodosFetchedState(_doneTodos, _notDoneTodos)));
    } catch (error) {
      emit(TodosOperationFailedState(error.toString()));
    }
  }

  FutureOr<void> handleSyncSelectedTodos(
      TodosSyncSelectedTodosEvent event, Emitter<TodosState> emit) async {
    try {
      if (_selectedTodos.isEmpty) {
        return;
      } else {
        _selectedTodosController.close();
        emit(TodosExitedEditingState());
        List<TodoModel> selectedTodosCopy =
            List.from(_selectedTodos.where((t) => !t.isSynced).toList());
        if (selectedTodosCopy.isEmpty) {
          emit(TodosOperationFailedState('All todos are synced 🚀'));
          emit(TodosFetchedState(_doneTodos, _notDoneTodos));
          return;
        }
        emit(TodosFetchedState(_doneTodos, _notDoneTodos,
            syncingTodos: selectedTodosCopy.map((e) => e.id).toList()));
        await Future.forEach(selectedTodosCopy, (todo) async {
          await TodosRepository.updateTodoInCloud(todo, manualUpload: true)
              .then((response) {
            if (response.success) {
              _notDoneTodos.any((t) => t.id == todo.id)
                  ? _notDoneTodos[
                          _notDoneTodos.indexWhere((t) => t.id == todo.id)]
                      .setIsSynced(true)
                  : _doneTodos[_doneTodos.indexWhere((t) => t.id == todo.id)]
                      .setIsSynced(true);
            }
          });
        }).then((_) => emit(TodosFetchedState(_doneTodos, _notDoneTodos)));
      }
    } catch (error) {
      emit(TodosOperationFailedState(error.toString()));
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
        _selectedTodosController.close();
        emit(TodosExitedEditingState());
        var selectedTodosCopy = List.from(_selectedTodos);
        emit(TodosFetchedState(_doneTodos, _notDoneTodos,
            syncingTodos: [..._selectedTodos.map((e) => e.id).toList()]));
        await Future.forEach(selectedTodosCopy, (todo) async {
          _selectedTodos.remove(todo);
          if (_doneTodos.contains(todo)) {
            _doneTodos.remove(todo);
          } else if (_notDoneTodos.contains(todo)) {
            _notDoneTodos.remove(todo);
          }
          await TodosRepository.removeTodo(todo.id);
        }).then((_) {
          _temp.clear();
          _selectedTodos.clear();
          emit(TodosExitedEditingState());
          if (_doneTodos.isNotEmpty || _notDoneTodos.isNotEmpty) {
            emit(TodosFetchedState(_doneTodos, _notDoneTodos));
          } else {
            emit(TodosEmptyState());
          }
        });
      }
    } catch (error) {
      emit(TodosOperationFailedState(error.toString()));
    }
  }
  FutureOr<void> handleSyncAllTodos(
      TodosSyncAllTodosEvent event, Emitter<TodosState> emit) async {
    try {
      List<TodoModel> toSyncTodos = [
        ..._notDoneTodos.where((t) => !t.isSynced && t.isUploaded),
        ..._doneTodos.where((t) => !t.isSynced && t.isUploaded)
      ];
      if (_notDoneTodos
          .any((t) => !t.isUploaded || _doneTodos.any((t) => !t.isUploaded))) {
        emit(TodosOperationFailedState(
            "Todos which are not uploaded will not be synced."));
      }
      if (toSyncTodos.isEmpty) {
        emit(TodosOperationFailedState('All todos are synced 🚀'));
        emit(TodosFetchedState(_doneTodos, _notDoneTodos));
        return;
      }
      emit(TodosFetchedState(_doneTodos, _notDoneTodos,
          syncingTodos: toSyncTodos.map((e) => e.id).toList()));
      await Future.forEach(toSyncTodos, (todo) async {
        await TodosRepository.updateTodoInCloud(todo, manualUpload: true)
            .then((response) {
          if (response.success) {
            _notDoneTodos.any((t) => t.id == todo.id)
                ? _notDoneTodos[
                        _notDoneTodos.indexWhere((t) => t.id == todo.id)]
                    .setIsSynced(true)
                : _doneTodos[_doneTodos.indexWhere((t) => t.id == todo.id)]
                    .setIsSynced(true);
          }
        });
      }).then((_) => emit(TodosFetchedState(_doneTodos, _notDoneTodos)));
    } catch (error) {
      emit(TodosOperationFailedState(error.toString()));
    }
  }
}
