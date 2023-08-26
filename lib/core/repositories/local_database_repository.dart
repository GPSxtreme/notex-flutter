import 'package:notex/data/models/todo_model.dart';
import 'package:notex/data/repositories/entitiy_to_json_repository.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/note_model.dart';
import 'package:path/path.dart';
import '../../main.dart';
import '../entities/note_data_entity.dart';
import '../entities/todo_data_entity.dart';

class LocalDatabaseRepository {
  late Database _database;

  Future<void> init() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'local_database.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        _createNoteTable(db);
        _createTodoTable(db);
      },
    );
  }

  void _createNoteTable(Database db) {
    try {
      db.execute('''
      CREATE TABLE notes (
        _id TEXT PRIMARY KEY,
        userId TEXT,
        title TEXT,
        body TEXT,
        createdTime TEXT,
        editedTime TEXT,
        __v INTEGER,
        isSynced INTEGER,
        isFavorite INTEGER,
        isUploaded INTEGER,
        isHidden INTEGER
      )
    ''');
    } catch (error) {
      rethrow;
    }
  }

  void _createTodoTable(Database db) {
    try {
      db.execute('''
      CREATE TABLE todos (
        _id TEXT PRIMARY KEY,
        userId TEXT,
        body TEXT,
        isCompleted INTEGER,
        createdTime TEXT,
        editedTime TEXT,
        expireTime TEXT,
        __v INTEGER,
        isSynced INTEGER,
        isUploaded INTEGER
      )
    ''');
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateNoteId(String oldId, String newId) async {
    try {
      await _database.update('notes', {'_id': newId},
          where: '_id = ?',
          whereArgs: [oldId],
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> setNoteIsHidden(String noteId, bool value) async{
    try {
      await _database.update('notes', {'isHidden': value ? 1 : 0},
          where: '_id = ?',
          whereArgs: [noteId],
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> insertNote(NoteDataEntity note, bool isSynced) async {
    final noteMap = EntityToJson.noteEntityToJson(note, isSynced);

    await _database.insert('notes', noteMap,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<NoteModel>> getNotes() async {
    final List<Map<String, dynamic>> maps = await _database
        .query('notes', where: 'userId = ?', whereArgs: [USER.data!.userId]);
    return List.generate(maps.length, (i) {
      return NoteModel.fromJsonOfLocalDb(maps[i]);
    });
  }

  Future<NoteModel> getNote(String noteId) async {
    final dbNote =
        await _database.query('notes', where: '_id = ?', whereArgs: [noteId]);
    return NoteModel.fromJsonOfLocalDb(dbNote.first);
  }

  Future<void> removeNote(String noteId) async {
    await _database.delete(
      'notes',
      where: '_id = ?',
      whereArgs: [noteId],
    );
  }

  Future<void> updateTodoId(String oldId, String newId) async {
    await _database.update(
      'todos',
      {'_id': newId},
      where: '_id = ?',
      whereArgs: [oldId],
    );
  }

  Future<void> insertTodo(TodoDataEntity todo, bool isSynced) async {
    final todoMap = EntityToJson.todoEntityToJson(todo, isSynced);
    await _database.insert('todos', todoMap,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeTodo(String todoId) async {
    await _database.delete(
      'todos',
      where: '_id = ?',
      whereArgs: [todoId],
    );
  }

  Future<void> updateTodo(TodoDataEntity todo) async {
    try {
      final todoMap = EntityToJson.todoEntityToJson(todo, false);
      // update record in todos table
      await _database.update(
        'todos',
        todoMap,
        where: '_id = ?',
        whereArgs: [todo.id],
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> setTodoSynced(String todoId, bool status) async {
    try {
      await _database.update('todos', {"isSynced": status ? 1 : 0},
          where: '_id = ?', whereArgs: [todoId]);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> setTodoUploaded(String todoId, bool value) async {
    try {
      await _database.update('todos', {"isUploaded": value ? 1 : 0},
          where: '_id = ?', whereArgs: [todoId]);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> setNoteSynced(String noteId, bool status) async {
    try {
      await _database.update('notes', {"isSynced": status ? 1 : 0},
          where: '_id = ?', whereArgs: [noteId]);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> setNoteUploaded(String noteId, bool value) async {
    try {
      await _database.update('notes', {"isUploaded": value ? 1 : 0},
          where: '_id = ?', whereArgs: [noteId]);
      return true;
    } catch (error) {
      return false;
    }
  }


  Future<bool> setNoteFavorite(String noteId, bool status) async {
    try {
      await _database.update('notes', {"isFavorite": status ? 1 : 0},
          where: '_id = ?', whereArgs: [noteId]);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> updateNote(NoteDataEntity note) async {
    try {
      final todoMap = EntityToJson.noteEntityToJson(note, false);
      // update record in todos table
      await _database.update(
        'notes',
        todoMap,
        where: '_id = ?',
        whereArgs: [note.id],
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<List<TodoModel>> getTodos() async {
    final List<Map<String, dynamic>> todos = await _database
        .query('todos', where: 'userId = ?', whereArgs: [USER.data!.userId]);
    return List.generate(todos.length, (i) {
      return TodoModel.fromJsonOfLocalDb(todos[i]);
    });
  }
}
