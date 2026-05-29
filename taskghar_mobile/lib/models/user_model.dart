// lib/models/user_model.dart
class UserModel {
  final String name;
  final String role;
  final String token;

  UserModel({
    required this.name,
    required this.role,
    required this.token,
  });

  // Maps the incoming Python JSON data response straight into a clean Dart Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['user']['name'],
      role: json['user']['role'],
      token: json['access_token'],
    );
  }
}