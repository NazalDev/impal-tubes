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
    // When coming from Supabase auth (signIn/signUp), extra fields are nested
    // under 'user_metadata'. When coming from the DB table they are flat.
    final meta = (map['user_metadata'] as Map<String, dynamic>?) ?? {};
    return UserModel(
      username: (map['username'] ?? meta['username'] ?? '') as String,
      email: (map['email'] ?? meta['email'] ?? '') as String,
      role: (map['role'] ?? meta['role'] ?? 'Pengguna') as String,
      avatar_url:
          (map['avatar_url'] ?? meta['avatar_url'] ?? 'default') as String,
      id: (map['id'] ?? '') as String,
    );
  }
}
