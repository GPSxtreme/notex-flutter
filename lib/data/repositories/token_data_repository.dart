import '../../core/entities/token_data_entity.dart';
import '../models/token_data_model.dart';

class TokenDataRepository {
  // Sample method to convert TokenDataModel to TokenDataEntity
  static TokenDataEntity mapToEntity(TokenDataModel model) {
    return TokenDataEntity(
      userId: model.userId,
      name: model.name,
      email: model.email,
    );
  }
}