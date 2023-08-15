import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:notex/core/repositories/auth_repository.dart';
import 'package:notex/core/repositories/shared_preferences_repository.dart';
import 'package:notex/data/models/updatable_user_data_model.dart';
import 'package:notex/data/models/update_user_data_reponse_model.dart';
import '../config/api_routes.dart';
import 'dart:io';

class UserRepository{
  static Future<UpdateUserDataResponseModel> updateUserData(UpdatableUserDataModel data)async{
    final url = Uri.parse(USER_UPDATE_USER_DATA);
    final body = jsonEncode(data.toJson());
    try{
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json',
          'Authorization' : AuthRepository.userToken},
        body: body,
      );
      final UpdateUserDataResponseModel updateResponse = updateUserDataResponseModelFromJson(response.body);
      if(updateResponse.success){
        //store token locally
        await SharedPreferencesRepository.saveJwtToken(updateResponse.token!);
      }
      return updateResponse;
    }catch(error){
      return UpdateUserDataResponseModel(success: false, message: "An unexpected error occurred, $error");
    }
  }
  static Future<bool> updateUserProfilePicture(File image) async{
    final url = Uri.parse(USER_PROFILE_PICTURE_UPLOAD_ROUTE);
    final request = http.MultipartRequest('POST',url);
    try{
      request.headers["Authorization"] = AuthRepository.userToken;
      final imageFile = await http.MultipartFile.fromPath('profilePicture', image.path);
      request.files.add(imageFile);
      final response = await request.send();
      if(response.statusCode == 200){
        return true;
      } else {
        return false;
      }
    }catch(error){
      if (kDebugMode) {
        print(error);
      }
      return false;
    }
  }
}