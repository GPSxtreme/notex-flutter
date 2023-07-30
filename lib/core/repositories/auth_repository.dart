import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notex/core/config/api_routes.dart';
import 'package:notex/core/repositories/shared_preferences_repository.dart';

import '../../data/models/login_response_model.dart';



class AuthRepository {

  static Future<void> registerUser(String email, String password) async {
    final url = Uri.parse(USER_REGISTER_ROUTE);
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        // Registration successful
        // You can handle success or return relevant data here if needed.
      } else {
        // Registration failed
        throw Exception('Failed to register user');
      }
    } catch (e) {
      // Error handling for network or server-related issues
      throw Exception('Failed to register user: $e');
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
}