// ignore_for_file: non_constant_identifier_names

class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String avatar_url;

  User({
    required this.username,
    required this.email,
    required this.role,
    required this.avatar_url,
    required this.id,
  });
}
