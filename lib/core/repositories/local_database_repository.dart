import 'package:notex/data/models/todo_model.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/note_model.dart';
import 'package:path/path.dart';
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
        isSynced INTEGER
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
        isSynced INTEGER
      )
    ''');
    } catch (error) {
      rethrow;
    }
  }

  Future<void> insertNote(NoteDataEntity note, bool isSynced) async {
    final noteMap = {
      '_id': note.id,
      'userId': note.userId,
      'title': note.title,
      'body': note.body,
      'createdTime': note.createdTime.toIso8601String(),
      'editedTime': note.editedTime.toIso8601String(),
      '__v': note.v,
      'isSynced': isSynced ? 1 : 0,
    };

    await _database.insert('notes', noteMap,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<NoteModel>> getNotes() async {
    final List<Map<String, dynamic>> maps = await _database.query('notes');
    return List.generate(maps.length, (i) {
      return NoteModel.fromJsonOfLocalDb(maps[i]);
    });
  }

  Future<void> insertTodo(TodoDataEntity todo, bool isSynced) async {
    final todoMap = {
      '_id': todo.id,
      'userId': todo.userId,
      'body': todo.body,
      // Store as 1 for true, 0 for false
      'isCompleted': todo.isCompleted ? 1 : 0,
      'createdTime': todo.createdTime.toIso8601String(),
      'editedTime': todo.editedTime.toIso8601String(),
      'expireTime': todo.expireTime.toIso8601String(),
      '__v': todo.v,
      'isSynced': isSynced ? 1 : 0,
    };

    await _database.insert('todos', todoMap,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TodoModel>> getTodos() async {
    final List<Map<String, dynamic>> todos = await _database.query('todos');
    return List.generate(todos.length, (i) {
      return TodoModel.fromJsonOfLocalDb(todos[i]);
    });
  }
}
