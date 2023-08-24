import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:notex/core/repositories/auth_repository.dart';
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
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AuthRepository.userToken
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
      onlineTodo.setIsUploaded(true);
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
      } else {
        final offlineTodo = offlineTodosMap[onlineTodo.id]!;
        if (onlineTodo.editedTime.isAfter(offlineTodo.editedTime)) {
          // Update local to-do only if online version has been edited more recently
          offlineTodosMap[onlineTodo.id] = TodoModel.fromJsonOfLocalDb(
              EntityToJson.todoEntityToJson(
                  ModelToEntityRepository.mapToTodoEntity(
                      model: onlineTodo, synced: true),
                  true));
          await LOCAL_DB.updateTodo(
            ModelToEntityRepository.mapToTodoEntity(
                model: onlineTodo, synced: true),
          );
        }
      }
    } // Convert the Map values back to a List
    final updatedOfflineTodosList = offlineTodosMap.values.toList();

    return updatedOfflineTodosList;
  }

  static Future<Map<String, dynamic>> addTodo(TodoModel todo) async {
    try {
      // Add to-do to local storage immediately
      await LOCAL_DB.insertTodo(
          ModelToEntityRepository.mapToTodoEntity(model: todo), false);
      // Trigger the cloud addition asynchronously without waiting for response
      final response = await addTodoToCloud(todo);
      return response;
    } catch (error) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> addTodoToCloud(TodoModel todo,
      {bool? manualUpload}) async {
    try {
      // Check if user has enabled auto sync
      if (SETTINGS.isAutoSyncEnabled || manualUpload == true) {
        final url = Uri.parse(TODO_ADD_ROUTE);
        final body = jsonEncode(todo.toJsonToServerAdd());

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': AuthRepository.userToken,
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
          // set to-do uploaded
          await LOCAL_DB.setTodoUploaded(fetchResponse.todoId, true);
          // set to-do synced
          final success =
              await LOCAL_DB.setTodoSynced(fetchResponse.todoId, true);
          return {'success': success, 'id': fetchResponse.todoId};
        } else {
          return {
            'success': false,
          };
        }
      }
    } catch (error) {
      // Handle any errors that might occur during cloud addition
      if (kDebugMode) {
        print("Error during cloud addition: $error");
      }
    }
    return {
      'success': false,
    };
  }

  static Future<void> _removeTodoFromCloud(String todoId) async {
    try {
      // Check if user has enabled auto sync
      if (SETTINGS.isAutoSyncEnabled) {
        final url = Uri.parse("$TODO_DELETE_ROUTE?todoId=$todoId");

        await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': AuthRepository.userToken
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
      await _removeTodoFromCloud(todoId);
    } catch (error) {
      rethrow;
    }
  }

  static Future<GenericServerResponse> updateTodoInCloud(TodoModel todo,
      {bool? manualUpload}) async {
    try {
      // Check if user has enabled auto sync
      if (manualUpload == true || SETTINGS.isAutoSyncEnabled) {
        final url = Uri.parse(TODO_UPDATE_ROUTE);
        final body = jsonEncode(todo.toJsonToServerUpdate());

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': AuthRepository.userToken,
          },
          body: body,
        );

        final GenericServerResponse fetchResponse =
            genericServerResponseFromJson(response.body);
        if (fetchResponse.success) {
          // Set note synced status based on server response
          await LOCAL_DB.setTodoSynced(todo.id, fetchResponse.success);
        }
        return fetchResponse;
      }
      return GenericServerResponse(
          success: false, message: 'auto sync disabled');
    } catch (error) {
      // Handle any errors that might occur during cloud update
      if (kDebugMode) {
        print("Error during cloud update: $error");
      }
      return GenericServerResponse(success: false, message: error.toString());
    }
  }
}
