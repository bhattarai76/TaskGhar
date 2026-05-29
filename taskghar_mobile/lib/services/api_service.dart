import 'package:dio/dio.dart';
import '../models/user_model.dart';

class ApiService {
  // 10.0.2.2 points the Android emulator to your laptop's Python server
// Inside lib/services/api_service.dart
// CHANGE THIS LINE:
final String _baseUrl = 'http://127.0.0.1:8000';
  final Dio _dio = Dio();

  Future<UserModel> loginUser(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      final errorDetail = e.response?.data['detail'] ?? 'Network pipeline disconnect';
      throw Exception(errorDetail);
    }
  }
} 