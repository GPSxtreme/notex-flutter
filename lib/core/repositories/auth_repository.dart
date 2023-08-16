import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notex/core/config/api_routes.dart';
import 'package:notex/core/repositories/jwt_decoder_repository.dart';
import 'package:notex/core/repositories/shared_preferences_repository.dart';
import 'package:notex/data/models/register_response_model.dart';
import 'package:notex/data/models/user_model.dart';

import '../../data/models/login_response_model.dart';



class AuthRepository {

  static late String userToken;

  static Future<void> initUserToken()async{
    try{
      final token = await SharedPreferencesRepository.getJwtToken();
      userToken = 'Bearer $token';
    }catch(e){
      throw Exception(e);
    }
  }

  static Future<UserDataModel?> getUserData()async{
    try{
      final userToken = await SharedPreferencesRepository.getJwtToken();
      if(userToken != null){
        return UserDataModel.fromJson(JwtDecoderRepository.decodeJwtToken(userToken)!);
      }
    }catch(e){
      rethrow;
    }
    return null;
  }

  static Future<RegisterResponseModel> registerUser(String email, String password,bool? remember) async {
    final url = Uri.parse(USER_REGISTER_ROUTE);
    final body = jsonEncode({
      'email': email,
      'password': password,
      'remember' : remember
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      final RegisterResponseModel registerResponse =  registerResponseModelFromJson(response.body);
      if(registerResponse.success){
        //store token locally
        await SharedPreferencesRepository.saveJwtToken(registerResponse.token!);
      }
      return registerResponse;
    } catch (e) {
      return RegisterResponseModel(success: false, message: "An unexpected error occurred, $e");
    }
  }

  static Future<LoginResponseModel> loginUser(String email, String password,bool? remember) async {
    final url = Uri.parse(USER_LOGIN_ROUTE);
    final body = jsonEncode({
      'email': email,
      'password': password,
      'remember' : remember ?? false
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      final LoginResponseModel loginResponse =  loginResponseModelFromJson(response.body);
      if(loginResponse.success){
        //store token locally
        await SharedPreferencesRepository.saveJwtToken(loginResponse.token!);
      }
      return loginResponse;
    } catch (e) {
      return LoginResponseModel(success: false, message: "An unexpected error occurred, $e");
    }
  }
  static Future<bool> logoutUser()async{
    await SharedPreferencesRepository.removeJwtToken();
    return true;
  }
}