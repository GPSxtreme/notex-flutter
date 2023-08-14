import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:notex/core/repositories/shared_preferences_repository.dart';
import 'package:http/http.dart' as http;
import 'package:notex/data/models/add_todo_response_model.dart';
import 'package:notex/data/models/get_todos_response_model.dart';
import 'package:notex/data/models/todo_model.dart';
import 'package:notex/data/repositories/entitiy_to_json_repository.dart';
import 'package:notex/data/repositories/model_to_entity_repository.dart';
import '../../data/models/generic_server_response.dart';
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
        offlineTodosMap[onlineTodo.id] = TodoModel.fromJsonOfLocalDb(
            EntityToJson.todoEntityToJson(
                ModelToEntityRepository.mapToTodoEntity(
                    model: onlineTodo, synced: true),
                true));
        await LOCAL_DB.insertTodo(
          ModelToEntityRepository.mapToTodoEntity(
              model: onlineTodo, synced: true),
          true,
        );
      } else if (offlineTodosMap[onlineTodo.id]!
          .editedTime
          .isBefore(onlineTodo.editedTime)) {
        // Update local to-do only if online version has been edited more recently
        offlineTodosMap[onlineTodo.id] = onlineTodo;
        await LOCAL_DB.updateTodo(
          ModelToEntityRepository.mapToTodoEntity(model: onlineTodo),
        );
        await LOCAL_DB.setTodoSynced(onlineTodo.id, true);
      }
    } // Convert the Map values back to a List
    final updatedOfflineTodosList = offlineTodosMap.values.toList();

    return updatedOfflineTodosList;
  }

  static Future<void> addTodo(TodoModel todo) async {
    try {
      // Add to-do to local storage immediately
      await LOCAL_DB.insertTodo(
          ModelToEntityRepository.mapToTodoEntity(model: todo), false);
      // Trigger the cloud addition asynchronously without waiting for response
      _addTodoToCloud(todo);
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> _addTodoToCloud(TodoModel todo) async {
    try {
      // Check if user has enabled auto sync
      final isAutoSyncEnabled = await SharedPreferencesRepository.getAutoSyncStatus();

      if (isAutoSyncEnabled == true) {
        final url = Uri.parse(TODO_ADD_ROUTE);
        final body = jsonEncode(todo.toJsonToServerAdd());
        final authToken = await SharedPreferencesRepository.getJwtToken();

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: body,
        );

        final GenericServerResponse serverResponse =
        genericServerResponseFromJson(response.body);

        if (serverResponse.success) {
          final AddTodoResponseModel fetchResponse =
          addTodoResponseModelFromJson(response.body);

          // Update local to-do id with the fetchResponse's
          await LOCAL_DB.updateTodoId(todo.id, fetchResponse.todoId);
        }
      }
    } catch (error) {
      // Handle any errors that might occur during cloud addition
      if (kDebugMode) {
        print("Error during cloud addition: $error");
      }
      rethrow;
    }
  }


  static Future<void> _removeTodoFromCloud(String todoId) async {
    try {
      // Check if user has enabled auto sync
      final isAutoSyncEnabled =
          await SharedPreferencesRepository.getAutoSyncStatus();

      if (isAutoSyncEnabled == true) {
        final url = Uri.parse("$TODO_DELETE_ROUTE?todoId=$todoId");
        final authToken = await SharedPreferencesRepository.getJwtToken();

        await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken'
          },
        );
      }
    } catch (error) {
      // Handle any errors that might occur during cloud removal
      if (kDebugMode) {
        print("Error during cloud removal: $error");
      }
      rethrow;
    }
  }

  static Future<void> removeTodo(String todoId) async {
    try {
      await LOCAL_DB.removeTodo(todoId);
      // remove to-do on server
      _removeTodoFromCloud(todoId);
    } catch (error) {
      rethrow;
    }
  }
}
