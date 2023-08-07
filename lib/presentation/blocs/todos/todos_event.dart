part of 'todos_bloc.dart';

@immutable
abstract class TodosEvent {}

class TodosInitialEvent extends TodosEvent {}

class TodosMarkTodoDoneEvent extends TodosEvent {
  final TodoModel todo;

  TodosMarkTodoDoneEvent(this.todo);
}

class TodosMarkTodoNotDoneEvent extends TodosEvent {
  final TodoModel todo;

  TodosMarkTodoNotDoneEvent(this.todo);
}

class TodosShowAddTodoDialogBoxEvent extends TodosEvent {}

class TodosAddTodoEvent extends TodosEvent {
  final TodoModel todo;
  TodosAddTodoEvent(this.todo);

}

class TodosEnteredEditingEvent extends TodosEvent {}

class TodosAreAllTodosSelectedEvent extends TodosEvent {
  final bool areSelected;

  TodosAreAllTodosSelectedEvent(this.areSelected);
}

class TodosIsTodoSelectedEvent extends TodosEvent {
  final bool isSelected;
  final TodoModel todo;
  TodosIsTodoSelectedEvent(this.isSelected, this.todo);
}

class TodosDeleteSelectedTodosEvent extends TodosEvent {}

class TodosHideSelectedTodosEvent extends TodosEvent {}

class TodosExitedEditingEvent extends TodosEvent {}