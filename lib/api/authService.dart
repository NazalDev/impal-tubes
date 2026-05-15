// ignore_for_file: non_constant_identifier_names

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  late String _user_id;
  final String _email;
  final String _password;

  AuthService({required String email, required String password})
    : _email = email,
      _password = password;

  Future<bool> login() async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: _email,
        password: _password,
      );

      if (response.user != null) {
        _user_id = response.user!.id;
      }

      return response.user != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _client.from('log').insert({
      'user_id': _user_id,
      'action': 'Logout',
      'logged_at': DateTime.now().toIso8601String(),
    });

    await _client.auth.signOut();
  }
}
