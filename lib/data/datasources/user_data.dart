import 'package:notex/core/repositories/auth_repository.dart';
import 'package:notex/data/models/user_model.dart';

class User{
  late UserDataModel? data;
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
  }

}