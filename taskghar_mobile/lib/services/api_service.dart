// lib/services/api_service.dart
import 'package:dio/dio.dart';
import '../models/user_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://127.0.0.1:8000'; 

  /// Tool 1: Handles Universal Login (Email OR Phone + Password)
  Future<UserModel> loginUser(String identifier, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {'identifier': identifier, 'password': password},
      );
      
      if (response.statusCode == 200) {
        return UserModel(
          name: response.data['name'],
          email: response.data['email'] ?? response.data['phone'], // Fallback
          role: response.data['role'],
        );
      } else {
        throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      final errorDetail = e.response?.data['detail'] ?? 'Login failed';
      throw Exception(errorDetail);
    }
  }

  /// Tool 2: Fetches Workers by Skill Category
  Future<List<dynamic>> getProvidersByCategory(String category) async {
    try {
      final response = await _dio.get('$_baseUrl/providers/$category');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load providers from database');
    }
  }

  /// Tool 3: 🚀 NEW - Asks the server to send an OTP to the user's phone or email
  Future<bool> sendVerificationCode(String contactInfo) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/send-verification', 
        data: {'contact_info': contactInfo}
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to send verification code');
    }
  }

  /// Tool 4: 🚀 UPDATED - Registration Pipeline (Now requires the OTP to pass!)
  Future<bool> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role, 
    required String otp, // Backend will check this!
    String? category,     
    String? rate,         
    String? experience,   
  }) async {
    try {
      final Map<String, dynamic> registrationData = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
        'otp': otp, 
      };

      if (role == 'tasker') {
        registrationData['category'] = category;
        registrationData['rate'] = rate;
        registrationData['experience'] = experience;
      }

      final response = await _dio.post(
        '$_baseUrl/auth/register',
        data: registrationData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      final errorDetail = e.response?.data['detail'] ?? 'Registration failed';
      throw Exception(errorDetail);
    }
  }

  /// Tool 5: Sends a new booking to the database
  Future<bool> createBooking({
    required String expertName,
    required String serviceType,
    required String date,
    required String address,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/bookings/create',
        data: {
          'expert_name': expertName,
          'service_type': serviceType,
          'date': date,
          'address': address,
          'description': description,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to send booking to server');
    }
  }

  /// Tool 6: Fetches incoming jobs for a specific Tasker
  Future<List<dynamic>> getExpertBookings(String expertName) async {
    try {
      final response = await _dio.get('$_baseUrl/bookings/$expertName');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load incoming jobs');
    }
  }
  /// Tool 7: Updates a job's status (Accept or Decline)
  Future<bool> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/bookings/$bookingId/status',
        data: {'status': newStatus},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update job status');
    }
  }
}
