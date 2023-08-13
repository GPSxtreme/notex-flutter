import 'package:notex/core/repositories/shared_preferences_repository.dart';
import 'package:notex/data/models/get_notes_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:notex/data/repositories/entitiy_to_json_repository.dart';
import 'package:notex/data/repositories/model_to_entity_repository.dart';
import '../../data/models/note_model.dart';
import '../config/api_routes.dart';
import '../../main.dart';

class NotesRepository {
  static Future<GetNotesResponseModel> fetchNotes() async {
    final url = Uri.parse(NOTE_GET_ROUTE);
    try {
      final authToken = await SharedPreferencesRepository.getJwtToken();
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken'
        },
      );
      final GetNotesResponseModel fetchResponse =
          getNotesResponseModelFromJson(response.body);
      return fetchResponse;
    } catch (error) {
      return GetNotesResponseModel(
          success: false, message: "An unexpected error occurred, $error");
    }
  }

  static Future<List<NoteModel>> syncOnlineNotes(
      List<NoteModel> onlineNotes) async {
    final List<NoteModel> offlineNotes = await LOCAL_DB.getNotes();

    final Map<String, NoteModel> offlineNotesMap = {
      for (var note in offlineNotes) note.id: note
    };

    for (final onlineNote in onlineNotes) {
      if (!offlineNotesMap.containsKey(onlineNote.id)) {
        // Note doesn't exist offline, insert it
        offlineNotesMap[onlineNote.id] = NoteModel.fromJsonOfLocalDb(
            EntityToJson.noteEntityToJson(
                ModelToEntityRepository.mapToNoteEntity(model: onlineNote,synced: true),
                true));
        await LOCAL_DB.insertNote(
          ModelToEntityRepository.mapToNoteEntity(model: onlineNote),
          true,
        );
      } else {
        // Note exists offline, compare edited times
        final offlineNote = offlineNotesMap[onlineNote.id]!;
        if (onlineNote.editedTime.isAfter(offlineNote.editedTime)) {
          // Online note is more recent, update the offline note
          offlineNotesMap[onlineNote.id] = onlineNote;
          await LOCAL_DB.updateNote(
            ModelToEntityRepository.mapToNoteEntity(model: onlineNote),
          );
          await LOCAL_DB.setNoteSynced(onlineNote.id, true);
        }
      }
    }

    // Convert the Map values back to a List
    final updatedOfflineNotesList = offlineNotesMap.values.toList();

    return updatedOfflineNotesList;
  }

  static Future<void> addNote(NoteModel note) async {
    try {
      await LOCAL_DB.insertNote(
          ModelToEntityRepository.mapToNoteEntity(model: note), false);
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> removeNote(String noteId) async {
    try {
      await LOCAL_DB.removeNote(noteId);
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> updateNote(NoteModel note) async {
    try {
      LOCAL_DB.updateNote(ModelToEntityRepository.mapToNoteEntity(model: note));
    } catch (error) {
      rethrow;
    }
  }
}
