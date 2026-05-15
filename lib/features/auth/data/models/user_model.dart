import 'package:volync/core/common/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.username,
    required super.email,
    required super.role,
    // ignore: non_constant_identifier_names
    required super.avatar_url,
    required super.id,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'Pengguna',
      avatar_url: map['avatar_url'] ?? 'default',
      id: map['id'] ?? '',
    );
  }
}
