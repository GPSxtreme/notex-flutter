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
    try{
      db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        userId TEXT,
        title TEXT,
        body TEXT,
        createdTime TEXT,
        editedTime TEXT,
        v INTEGER
        synced BOOLEAN
      )
    ''');
    } catch (error){
      rethrow;
    }
  }

  void _createTodoTable(Database db) {
    try{
      db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        userId TEXT,
        body TEXT,
        isCompleted BOOLEAN,
        createdTime TEXT,
        editedTime TEXT,
        expireTime TEXT,
        v INTEGER
        synced BOOLEAN
      )
    ''');
    }catch(error){
      rethrow;
    }
  }

  Future<void> insertNote(NoteDataEntity note) async {
    final noteMap = {
      'id': note.id,
      'userId': note.userId,
      'title': note.title,
      'body': note.body,
      'createdTime': note.createdTime.toIso8601String(),
      'editedTime': note.editedTime.toIso8601String(),
      'v': note.v,
      'synced' : false,
    };

    await _database.insert('notes', noteMap,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<NoteModel>> getNotes() async {
    final List<Map<String, dynamic>> maps = await _database.query('notes');
    return List.generate(maps.length, (i) {
      return NoteModel.fromJson(maps[i]);
    });
  }

  Future<void> insertTodo(TodoDataEntity todo) async {
    final todoMap = {
      'id': todo.id,
      'userId': todo.userId,
      'body': todo.body,
      'isCompleted': todo.isCompleted, // Store as 1 for true, 0 for false
      'createdTime': todo.createdTime.toIso8601String(),
      'editedTime': todo.editedTime.toIso8601String(),
      'expireTime': todo.expireTime.toIso8601String(),
      'v': todo.v,
      'synced': false,
    };

    await _database.insert('todos', todoMap,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TodoModel>> getTodos() async {
    final List<Map<String, dynamic>> maps = await _database.query('todos');
    return List.generate(maps.length, (i) {
      return TodoModel.fromJson(maps[i]);
    });
  }
}