part of 'todos_bloc.dart';

@immutable
abstract class TodosEvent {}

class TodosInitialEvent extends TodosEvent {}

class TodosRefetchTodosEvent extends TodosEvent{
  final TodoModel? todo;
  TodosRefetchTodosEvent(this.todo);
}

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
  final bool areAllSelected;

  TodosAreAllTodosSelectedEvent(this.areAllSelected);
}

class TodosSetAllTodosSelectedCheckBoxEvent extends TodosEvent {
  final bool flag;

  TodosSetAllTodosSelectedCheckBoxEvent(this.flag);
}

class TodosIsTodoSelectedEvent extends TodosEvent {
  final bool isSelected;
  final TodoModel todo;
  TodosIsTodoSelectedEvent(this.isSelected, this.todo);
}

class TodosDeleteSelectedTodosEvent extends TodosEvent {}

class TodosHideSelectedTodosEvent extends TodosEvent {}

class TodosExitedEditingEvent extends TodosEvent {}

class TodosUploadTodosToCloudEvent extends TodosEvent {
  final List<TodoModel> todos;
  TodosUploadTodosToCloudEvent(this.todos);
}

class TodosSyncSelectedTodosEvent extends TodosEvent{}