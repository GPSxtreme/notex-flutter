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

class TodosShowAddTodoDialogBoxEvent extends TodosEvent {
  final BuildContext context;

  TodosShowAddTodoDialogBoxEvent(this.context);
}
