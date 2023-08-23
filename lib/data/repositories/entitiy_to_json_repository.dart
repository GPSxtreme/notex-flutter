
import 'package:notex/core/entities/note_data_entity.dart';
import 'package:notex/core/entities/todo_data_entity.dart';

class EntityToJson {
  static Map<String,dynamic> noteEntityToJson(NoteDataEntity note, bool isSynced){
    final noteMap = {
      '_id': note.id,
      'userId': note.userId,
      'title': note.title,
      'body': note.body,
      'createdTime': note.createdTime.toIso8601String(),
      'editedTime': note.editedTime.toIso8601String(),
      '__v': note.v,
      'isSynced': isSynced ? 1 : 0,
      'isFavorite' : note.isFavorite ? 1 : 0,
      'isUploaded' : note.isUploaded ? 1 : 0
    };
    return noteMap;
  }

  static Map<String,dynamic> todoEntityToJson(TodoDataEntity todo, bool isSynced){
    final todoMap = {
      '_id': todo.id,
      'userId': todo.userId,
      'body': todo.body,
      'isCompleted': todo.isCompleted ? 1 : 0,
      'createdTime': todo.createdTime.toIso8601String(),
      'editedTime': todo.editedTime.toIso8601String(),
      'expireTime': todo.expireTime.toIso8601String(),
      '__v': todo.v,
      'isSynced': isSynced ? 1 : 0,
    };
    return todoMap;
  }
}