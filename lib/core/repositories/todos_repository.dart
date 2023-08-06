import 'package:notex/core/repositories/shared_preferences_repository.dart';
import 'package:http/http.dart' as http;
import 'package:notex/data/models/get_todos_response_model.dart';
import 'package:notex/data/models/todo_model.dart';
import 'package:notex/data/repositories/model_to_entity_repository.dart';
import '../config/api_routes.dart';
import '../../main.dart';

class TodosRepository {
  static Future<GetTodosResponseModel> fetchTodos() async {
    final url = Uri.parse(TODO_GET_ROUTE);
    try {
      final authToken = await SharedPreferencesRepository.getJwtToken();
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken'
        },
      );
      final GetTodosResponseModel fetchResponse =
      getTodosResponseModelFromJson(response.body);
      return fetchResponse;
    } catch (error) {
      return GetTodosResponseModel(
          success: false, message: "An unexpected error occurred, $error");
    }
  }

  static Future<List<TodoModel>> syncOnlineTodos(
      List<TodoModel> onlineTodos) async {
    final Map<String, TodoModel> offlineTodosMap = {
      for (var todo in await LOCAL_DB.getTodos()) todo.id: todo
    };

    for (final onlineTodo in onlineTodos) {
      if (!offlineTodosMap.containsKey(onlineTodo.id)) {
        offlineTodosMap[onlineTodo.id] = onlineTodo;
        await LOCAL_DB.insertTodo(
          ModelToEntityRepository.mapToTodoEntity(model: onlineTodo),
          true,
        );
      }else if (offlineTodosMap[onlineTodo.id]!.editedTime.isBefore(onlineTodo.editedTime)) {
        // Update local to-do only if online version has been edited more recently
        offlineTodosMap[onlineTodo.id] = onlineTodo;
        await LOCAL_DB.updateTodo(
          ModelToEntityRepository.mapToTodoEntity(model: onlineTodo),
        );
        await LOCAL_DB.setTodoSynced(onlineTodo.id, true);
      }
    }// Convert the Map values back to a List
    final updatedOfflineTodosList = offlineTodosMap.values.toList();

    return updatedOfflineTodosList;
  }
}
