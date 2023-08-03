part of 'todos_bloc.dart';

@immutable
abstract class TodosState {}

abstract class TodosActionState extends TodosState {}

class TodosInitialState extends TodosState {}

class TodosFetchingState extends TodosState {}

class TodosFetchedState extends TodosState {
  final List<TodoModel> todos;
  TodosFetchedState(this.todos);
}

class TodosFetchingFailedState extends TodosState {
  final String reason;

  TodosFetchingFailedState(this.reason);
}

class TodosLoadingState extends TodosState{}

class TodosLoadedState extends TodosState{}

class TodosEmptyState extends TodosState {}


