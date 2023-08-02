import '../../core/entities/note_data_entity.dart';
import '../../core/entities/todo_data_entity.dart';
import '../../core/entities/token_data_entity.dart';
import '../models/note_model.dart';
import '../models/todo_model.dart';
import '../models/token_data_model.dart';

class ModelToEntityRepository {
  static TokenDataEntity mapToTokenEntity(TokenDataModel model) {
    return TokenDataEntity(
      userId: model.userId,
      name: model.name,
      email: model.email,
    );
  }

  static NoteDataEntity mapToNoteEntity(NoteModel model) {
    return NoteDataEntity(
      id: model.id,
      userId: model.userId,
      title: model.title,
      body: model.body,
      createdTime: model.createdTime,
      editedTime: model.editedTime,
      v: model.v,
    );
  }

  static TodoDataEntity mapToTodoEntity(TodoModel model) {
    return TodoDataEntity(
      id: model.id,
      userId: model.userId,
      body: model.body,
      isCompleted: model.isCompleted,
      createdTime: model.createdTime,
      editedTime: model.editedTime,
      expireTime: model.expireTime,
      v: model.v,
    );
  }
}
