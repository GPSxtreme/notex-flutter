part of 'todos_bloc.dart';

@immutable
abstract class TodosState {}

abstract class TodosActionState extends TodosState {}

class TodosInitialState extends TodosState {}

class TodosFetchingState extends TodosState {}

class TodosFetchedState extends TodosState {
  final List<TodoModel> doneTodos;
  final List<TodoModel> notDoneTodos;
  final bool isInEditState;
  final bool areAllSelected;

  TodosFetchedState(
    this.doneTodos,
    this.notDoneTodos, {
    this.isInEditState = false,
    this.areAllSelected = false,
  });
}

class TodosFetchingFailedState extends TodosState {
  final String reason;

  TodosFetchingFailedState(this.reason);
}

class TodosLoadingState extends TodosState {}

class TodosLoadedState extends TodosState {}

class TodosEmptyState extends TodosState {}

class TodosTodoDoneState extends TodosState {}

class TodosTodoUndoneState extends TodosState {}

class TodosShowAddTodoDialogBoxState extends TodosActionState {}

class TodosAddTodoSuccessState extends TodosActionState {}

class TodosAddTodoFailedState extends TodosActionState {
  final String reason;

  TodosAddTodoFailedState(this.reason);
}

class TodosOperationFailedState extends TodosActionState {
  final String reason;
  TodosOperationFailedState(this.reason);
}

class TodosEnteredEditingState extends TodosActionState {}

class TodosExitedEditingState extends TodosActionState {}

class TodosManageAnimationsOfRemoved extends TodosActionState {
  final List<TodoModel> removedTodos;
  final List<TodoModel> doneTodos;
  final List<TodoModel> notDoneTodos;

  TodosManageAnimationsOfRemoved(this.removedTodos, this.doneTodos, this.notDoneTodos);
}