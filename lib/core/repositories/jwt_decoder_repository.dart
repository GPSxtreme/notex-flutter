import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class JwtDecoderRepository {
  // Method to decode the JWT token and extract user data
  static Map<String, dynamic>? decodeJwtToken(String token) {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error decoding JWT token: $e');
      }
      return null;
    }
  }
  // Method to verify the validity of the JWT token
  static bool verifyJwtToken(String token) {
    try {
      DateTime expirationDate = JwtDecoder.getExpirationDate(token);
      bool isExpired = DateTime.now().isAfter(expirationDate);
      return !isExpired;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying JWT token: $e');
      }
    }
    return false;
  }

}
