part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignUp extends AuthEvent {
  final String username;
  final String email;
  final String password;

  AuthSignUp({
    required this.username,
    required this.email,
    required this.password,
  });
}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({required this.email, required this.password});
}

final class AuthIsUserLoggedIn extends AuthEvent {}

final class AuthEditProfile extends AuthEvent {
  final String? username;
  /// Local file to upload as the new avatar.  Null = keep existing.
  final File? avatarFile;
  final String? oldPassword;
  final String? newPassword;

  AuthEditProfile({
    this.username,
    this.avatarFile,
    this.oldPassword,
    this.newPassword,
  });
}

final class AuthResetPassword extends AuthEvent {
  final String username;
  final String email;
  final String newPassword;

  AuthResetPassword({
    required this.username,
    required this.email,
    required this.newPassword,
  });
}
