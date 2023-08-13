part of 'todos_bloc.dart';

@immutable
abstract class TodosState {}

abstract class TodosHomeState extends TodosState{}

abstract class TodosActionState extends TodosState {}

abstract  class TodosHomeActionState extends TodosActionState {}

class TodosInitialState extends TodosState {}

class TodosFetchingState extends TodosHomeState{}

class TodosFetchedState extends TodosHomeState {
  final List<TodoModel> doneTodos;
  final List<TodoModel> notDoneTodos;


  TodosFetchedState(
    this.doneTodos,
    this.notDoneTodos);
}

class TodosEditingState extends TodosFetchedState {
  TodosEditingState(super.doneTodos, super.notDoneTodos,
      {this.areAllSelected = false, this.selectedTodoIds});
  final bool areAllSelected;
  final List<String>? selectedTodoIds;
}

class TodosFetchingFailedState extends TodosState {
  final String reason;

  TodosFetchingFailedState(this.reason);
}

class TodosLoadingState extends TodosState {}

class TodosLoadedState extends TodosState {}

class TodosEmptyState extends TodosHomeState {}

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

class TodosEnteredEditingState extends TodosHomeState {}

class TodosExitedEditingState extends TodosHomeState {}

class TodosSetAllTodosSelectedCheckBoxState extends TodosHomeActionState{
  final bool flag;
  TodosSetAllTodosSelectedCheckBoxState(this.flag);
}