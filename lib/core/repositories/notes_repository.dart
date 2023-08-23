import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:notex/core/repositories/auth_repository.dart';
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
  static Future<GetNotesResponseModel> fetchNotesFromOnline() async {
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
      onlineNote.setIsUploaded(true);
      if (!offlineNotesMap.containsKey(onlineNote.id)) {
        // Note doesn't exist offline, insert it
        offlineNotesMap[onlineNote.id] = NoteModel.fromJsonOfLocalDb(
            EntityToJson.noteEntityToJson(
                ModelToEntityRepository.mapToNoteEntity(
                    model: onlineNote),
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
          offlineNotesMap[onlineNote.id] = NoteModel.fromJsonOfLocalDb(
              EntityToJson.noteEntityToJson(
                  ModelToEntityRepository.mapToNoteEntity(
                      model: onlineNote, synced: true),
                  true));
          await LOCAL_DB.updateNote(
            ModelToEntityRepository.mapToNoteEntity(model: onlineNote),
          );
        }
      }
    }

    // Convert the Map values back to a List
    List<NoteModel> updatedOfflineNotesList = offlineNotesMap.values.toList();
    return updatedOfflineNotesList;
  }

  static Future<Map<String,dynamic>> addNote(NoteModel note) async {
    try {
      // Add note to local storage immediately
      await LOCAL_DB.insertNote(
        ModelToEntityRepository.mapToNoteEntity(model: note),
        false,
      );
      // Trigger the cloud addition asynchronously without waiting for response
      final response =  await addNoteToCloud(note);
      return response;
    } catch (error) {
      rethrow;
    }
  }

  static Future<Map<String,dynamic>> addNoteToCloud(NoteModel note ,
      {bool? manualUpload}) async {
    try {
      // Check if user has enabled auto sync
      if (manualUpload == true || SETTINGS.isAutoSyncEnabled) {
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
          await LOCAL_DB.updateNoteId(note.id, fetchResponse.noteId);
          // set note uploaded
          await LOCAL_DB.setNoteUploaded(fetchResponse.noteId, true);
          // Set note synced and return the result
          final success = await LOCAL_DB.setNoteSynced(fetchResponse.noteId, true);

          return {
            'success' : success,
            'id' : fetchResponse.noteId
          };
        } else {
          return {
            'success' : false,
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
      'success' : false,
    };
  }


  static Future<bool> removeNote(String noteId) async {
    try {
      // Remove note from local storage immediately
      await LOCAL_DB.removeNote(noteId);
      // Trigger the cloud removal asynchronously without waiting for response
      final response = _removeNoteFromCloud(noteId);
      return response;
    } catch (error) {
      return false;
    }
  }

  static Future<bool> _removeNoteFromCloud(String noteId) async {
    try {
      // Check if user has enabled auto sync
      if (SETTINGS.isAutoSyncEnabled) {
        final url = Uri.parse("$NOTE_DELETE_ROUTE?noteId=$noteId");

       final response =  await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': AuthRepository.userToken,
          },
        );
       final GenericServerResponse serverResponse = genericServerResponseFromJson(response.body);
       return serverResponse.success;
      } else {
        return false;
      }
    } catch (error) {
      // Handle any errors that might occur during cloud removal
      if (kDebugMode) {
        print("Error during cloud removal: $error");
      }
      return false;
    }
  }

  static Future<GenericServerResponse> updateNote(NoteModel note) async {
    try {
      // Update note in local storage immediately
      await LOCAL_DB.updateNote(ModelToEntityRepository.mapToNoteEntity(model: note));
      // set note un-synced
      await LOCAL_DB.setNoteSynced(note.id, false);
      // Trigger the cloud update asynchronously without waiting for response
      final response =  updateNoteInCloud(note);
      return response;
    } catch (error) {
      rethrow;
    }
  }

  static Future<GenericServerResponse> updateNoteInCloud(NoteModel note ,{bool? manualUpload}) async {
    try {
      // Check if user has enabled auto sync
      if (manualUpload == true || SETTINGS.isAutoSyncEnabled) {
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
        if(fetchResponse.success){
          // Set note synced status based on server response
          await LOCAL_DB.setNoteSynced(note.id, fetchResponse.success);
        }
        return fetchResponse;
      }
      return GenericServerResponse(success: false, message: 'auto sync disabled');
    } catch (error) {
      // Handle any errors that might occur during cloud update
      if (kDebugMode) {
        print("Error during cloud update: $error");
      }
      return  GenericServerResponse(success: false, message: error.toString());
    }
  }

  static Future<void> setNoteFavorite(String id,bool value)async{
    // update favorite field
    await LOCAL_DB.setNoteFavorite(id, value);
    // update status
    await LOCAL_DB.setNoteSynced(id,false);
  }
}
