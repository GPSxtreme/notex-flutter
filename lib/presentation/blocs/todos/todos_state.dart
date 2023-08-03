part of 'todos_bloc.dart';

@immutable
abstract class TodosState {}

abstract class TodosActionState extends TodosState {}

class TodosInitialState extends TodosState {}

class TodosFetchingState extends TodosState {}

class TodosFetchedState extends TodosState {
  final List<TodoModel> doneTodos;
  final List<TodoModel> notDoneTodos;
  TodosFetchedState(this.doneTodos, this.notDoneTodos);
}

class TodosFetchingFailedState extends TodosState {
  final String reason;

  TodosFetchingFailedState(this.reason);
}

class TodosLoadingState extends TodosState{}

class TodosLoadedState extends TodosState{}

class TodosEmptyState extends TodosState {}

class TodosTodoDoneState extends TodosState {}

class TodosTodoUndoneState extends TodosState {}