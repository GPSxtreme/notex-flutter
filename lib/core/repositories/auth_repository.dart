import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notex/core/config/api_routes.dart';
import 'package:notex/core/repositories/jwt_decoder_repository.dart';
import 'package:notex/core/repositories/shared_preferences_repository.dart';
import 'package:notex/data/models/generic_server_response.dart';
import 'package:notex/data/models/register_response_model.dart';
import 'package:notex/data/models/user_model.dart';

import '../../data/models/login_response_model.dart';
import '../../main.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth/local_auth.dart';



class AuthRepository {

  static late String userToken;
  static LocalAuthentication localAuth = LocalAuthentication();

  static Future<void> init()async{
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
    USER.destroy();
    return true;
  }
  static Future<GenericServerResponse> sendAccountVerificationEmail()async{
    final url = Uri.parse(USER_ACCOUNT_VERIFY_ROUTE);
    final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json','Authorization':AuthRepository.userToken},
      );
    return genericServerResponseFromJson(response.body);
  }
  static Future<GenericServerResponse> sendPasswordResetLink({String? email})async{
    final url = Uri.parse(USER_PASSWORD_RESET_ROUTE);
    final body = json.encode(
      {
        'email' : email ?? USER.data!.email
      }
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body
    );
    return genericServerResponseFromJson(response.body);
  }
  static Future<bool> authenticateUser({bool isNotes = true})async{
    try{
      final bool canAuthenticateWithBiometrics = await localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await localAuth.isDeviceSupported();
      final List<BiometricType> availableBiometrics =
      await localAuth.getAvailableBiometrics();
      if (canAuthenticate &&  availableBiometrics.isNotEmpty) {
        // Some biometrics are enrolled.
        bool response = await localAuth.authenticate(
            localizedReason: isNotes?  'Please authenticate to show content' : 'App locked',
            options: AuthenticationOptions(biometricOnly: SETTINGS.isBiometricOnly,useErrorDialogs: true,sensitiveTransaction: true,stickyAuth: true),
            authMessages: const <AuthMessages>[
              AndroidAuthMessages(
                  signInTitle: 'Verify that its you!',
                  cancelButton: 'Cancel',
                  goToSettingsButton: 'Open settings',
                  biometricSuccess: 'Success!'
              ),
            ]);
        return response;
      } else{
        return false;
      }
    }catch(e){
      return false;
    }
  }
}