import 'package:flutter/foundation.dart';
import 'package:notex/core/repositories/auth_repository.dart';
import 'package:notex/core/repositories/shared_preferences_repository.dart';
import 'package:notex/data/models/user_model.dart';

class User{
  late UserDataModel? data;
  late String profilePictureCacheKey;
  void setData(UserDataModel newData) => data = newData;

  Future<void> init()async{
    try{
      await AuthRepository.getUserData().then(
              (res){
            if(res != null){
              setData(res);
              if (kDebugMode) {
                print(data!.toJson());
              }
            }
          }
      );
      await SharedPreferencesRepository.getProfilePictureCacheKey().then(
              (key)async{
            if(key == null){
              profilePictureCacheKey = await SharedPreferencesRepository.generateProfilePictureCacheKey();
            } else{
              profilePictureCacheKey = key;
            }
          }
      );
    }catch(error){
      throw Exception(error);
    }
  }
  void destroy(){
    data = null;
  }
}