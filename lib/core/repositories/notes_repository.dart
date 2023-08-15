import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:notex/core/repositories/auth_repository.dart';
import 'package:notex/core/repositories/shared_preferences_repository.dart';
import 'package:notex/data/models/generic_server_response.dart';
import 'package:notex/data/models/get_notes_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:notex/data/repositories/entitiy_to_json_repository.dart';
import 'package:notex/data/repositories/model_to_entity_repository.dart';
import '../../data/models/add_note_response_model.dart';
import '../../data/models/note_model.dart';
import '../config/api_routes.dart';
import '../../main.dart';

class NotesRepository {
  static Future<GetNotesResponseModel> fetchNotes() async {
    final url = Uri.parse(NOTE_GET_ROUTE);
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AuthRepository.userToken
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
                ModelToEntityRepository.mapToNoteEntity(
                    model: onlineNote, synced: true),
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
      // Add note to local storage immediately
      await LOCAL_DB.insertNote(
        ModelToEntityRepository.mapToNoteEntity(model: note),
        false,
      );
      // Trigger the cloud addition asynchronously without waiting for response
      _addNoteToCloud(note);
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> _addNoteToCloud(NoteModel note) async {
    try {
      // Check if user has enabled auto sync
      final isAutoSyncEnabled =
          await SharedPreferencesRepository.getAutoSyncStatus();

      if (isAutoSyncEnabled == true) {
        final url = Uri.parse(NOTE_ADD_ROUTE);
        final body = jsonEncode(note.toJsonToServerAdd());

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
          final AddNoteResponseModel fetchResponse =
              addNoteResponseModelFromJson(response.body);

          // Update local note id with the fetchResponse's asynchronously
          _updateLocalNoteId(note.id, fetchResponse.noteId);
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

  static Future<void> _updateLocalNoteId(String oldId, String newId) async {
    try {
      // Perform the update of the local note id
      await LOCAL_DB.updateNoteId(oldId, newId);
    } catch (error) {
      // Handle any errors that might occur during the update
      if (kDebugMode) {
        print("Error during local note id update: $error");
      }
      rethrow;
    }
  }

  static Future<void> removeNote(String noteId) async {
    try {
      // Remove note from local storage immediately
      await LOCAL_DB.removeNote(noteId);

      // Trigger the cloud removal asynchronously without waiting for response
      _removeNoteFromCloud(noteId);
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> _removeNoteFromCloud(String noteId) async {
    try {
      // Check if user has enabled auto sync
      final isAutoSyncEnabled = await SharedPreferencesRepository.getAutoSyncStatus();

      if (isAutoSyncEnabled == true) {
        final url = Uri.parse("$NOTE_DELETE_ROUTE?noteId=$noteId");

        await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': AuthRepository.userToken,
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

  static Future<void> updateNote(NoteModel note) async {
    try {
      // Update note in local storage immediately
      await LOCAL_DB.updateNote(ModelToEntityRepository.mapToNoteEntity(model: note));

      // Trigger the cloud update asynchronously without waiting for response
      _updateNoteInCloud(note);
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> _updateNoteInCloud(NoteModel note) async {
    try {
      // Check if user has enabled auto sync
      final isAutoSyncEnabled = await SharedPreferencesRepository.getAutoSyncStatus();

      if (isAutoSyncEnabled == true) {
        final url = Uri.parse(NOTE_UPDATE_ROUTE);
        final body = jsonEncode(note.toJsonToServerUpdate());

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

        // Set note synced status based on server response
        await LOCAL_DB.setNoteSynced(note.id, fetchResponse.success);
      }
    } catch (error) {
      // Handle any errors that might occur during cloud update
      if (kDebugMode) {
        print("Error during cloud update: $error");
      }
    }
  }

}
