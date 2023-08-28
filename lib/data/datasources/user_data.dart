import 'package:notex/core/repositories/auth_repository.dart';
import 'package:notex/core/repositories/shared_preferences_repository.dart';
import 'package:notex/data/models/user_model.dart';

class User{
  late UserDataModel? data;
  late String profilePictureCacheKey;
  void setData(UserDataModel newData) => data = newData;

  Future<void> init()async{
    await AuthRepository.getUserData().then(
        (res){
          if(res != null){
           setData(res);
           print(data!.toJson());
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
  }

}