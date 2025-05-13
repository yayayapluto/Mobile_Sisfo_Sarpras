import 'mandatory.dart';

class User extends Mandatory {
  final String username;
  final String? email;
  final String? phone;
  final String role;

  User({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.username,
    this.email,
    this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      username: json['username'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String,
    );
  }
}
