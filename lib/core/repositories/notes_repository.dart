import 'package:notex/core/repositories/shared_preferences_repository.dart';
import 'package:notex/data/models/get_notes_response_model.dart';
import 'package:http/http.dart' as http;
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
    final Map<String, NoteModel> offlineNotesMap = {
      for (var note in await LOCAL_DB.getNotes()) note.id: note
    };

    for (final onlineNote in onlineNotes) {
      if (offlineNotesMap.containsKey(onlineNote.id)) {
        offlineNotesMap[onlineNote.id] = onlineNote;
      } else {
        offlineNotesMap[onlineNote.id] = onlineNote;
        await LOCAL_DB.insertNote(
          ModelToEntityRepository.mapToNoteEntity(onlineNote),
          true,
        );
      }
    }// Convert the Map values back to a List
    final updatedOfflineNotesList = offlineNotesMap.values.toList();

    return updatedOfflineNotesList;
  }
}
